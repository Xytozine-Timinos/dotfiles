import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Mpris

PanelWindow {
    id: window
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    WlrLayershell.layer: WlrLayer.Background
    color: "transparent"

    // Grab the active MPRIS player (first one found, or the one currently playing)
    property var player: {
        for (const p of Mpris.players.values) {
            if (p.isPlaying) return p;
        }
        return Mpris.players.values[0] ?? null;
    }

    // Background box surrounding the player
    Rectangle {
        id: playerBox
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
	anchors.bottomMargin: 38
        width: playerRow.width + 48
        height: playerRow.height + 32
        radius: 10
        color: "#E816161D"
        visible: window.player !== null

        RowLayout {
            id: playerRow
            anchors.centerIn: parent
            spacing: 16

            // Album art
            Rectangle {
                width: 72
                height: 72
                radius: 8
                color: "#33FFFFFF"
                clip: true

                Image {
                    anchors.fill: parent
                    source: window.player?.trackArtUrl ?? ""
                    fillMode: Image.PreserveAspectCrop
                    visible: source != ""
                }
            }

            // Track info + controls
            Column {
                spacing: 8

                Text {
                    text: window.player?.trackTitle ?? "Nothing playing"
                    color: "#FFFFFF"
                    font.pixelSize: 20
                    font.weight: Font.Bold
                    font.family: "JetBrainsMono NerdFont"
                    style: Text.Outline
                    styleColor: "#40000000"
                    elide: Text.ElideRight
                    width: 260
                }

                Text {
                    text: window.player?.trackArtist ?? ""
                    color: "#D0D0D0"
                    font.pixelSize: 14
                    font.family: "JetBrainsMono NerdFont"
                    style: Text.Outline
                    styleColor: "#40000000"
                    elide: Text.ElideRight
                    width: 260
                }

                // Progress bar (click or drag to seek)
                Rectangle {
                    id: progressBar
                    width: 260
                    height: 4
                    radius: 2
                    color: "#40FFFFFF"

                    property bool canSeek: window.player?.canSeek ?? false
                    property real ratio: {
                        const len = window.player?.length ?? 0;
                        const pos = window.player?.position ?? 0;
                        return len > 0 ? pos / len : 0;
                    }

                    Rectangle {
                        height: parent.height
                        radius: 2
                        color: "#FFFFFF"
                        width: progressBar.width * progressBar.ratio
                    }

                    // Slightly bigger hit area than the visual bar, easier to grab
                    MouseArea {
                        id: seekArea
                        anchors.fill: parent
                        anchors.topMargin: -6
                        anchors.bottomMargin: -6
                        enabled: progressBar.canSeek
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor

                        function seekToX(x) {
                            const len = window.player?.length ?? 0;
                            if (len <= 0) return;
                            const clamped = Math.max(0, Math.min(x, progressBar.width));
                            const newPos = (clamped / progressBar.width) * len;
                            window.player.position = newPos;
                        }

                        onPressed: (mouse) => seekToX(mouse.x)
                        onPositionChanged: (mouse) => {
                            if (pressed) seekToX(mouse.x);
                        }
                    }
                }

                // Controls
                Row {
                    spacing: 20
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        text: "\uf048" // previous icon (nerd font)
                        color: "#FFFFFF"
                        font.pixelSize: 25
                        font.family: "JetBrainsMono NerdFont"
                        MouseArea {
                            anchors.fill: parent
                            onClicked: window.player?.previous()
                        }
                    }

                    Text {
                        text: window.player?.isPlaying ? "\uf04c" : "\uf04b" // pause / play
                        color: "#FFFFFF"
                        font.pixelSize: 25
                        font.family: "JetBrainsMono NerdFont"
                        MouseArea {
                            anchors.fill: parent
                            onClicked: window.player?.togglePlaying()
                        }
                    }

                    Text {
                        text: "\uf051" // next icon
                        color: "#FFFFFF"
                        font.pixelSize: 25
                        font.family: "JetBrainsMono NerdFont"
                        MouseArea {
                            anchors.fill: parent
                            onClicked: window.player?.next()
                        }
                    }
                }
            }
        }
    }

    // Poll for position updates every second so the progress bar moves
    Timer {
        interval: 1000
        running: window.player?.isPlaying ?? false
        repeat: true
        onTriggered: window.player?.positionChanged()
    }
}
