import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: window

    // Anchoring to all edges and setting exclusive margin to -1 ensures
    // the window covers the full screen as a background overlay.
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    // Wayland/Hyprland specific layer protocol settings
    WlrLayershell.layer: WlrLayer.Background
    color: "transparent"

    // Timer to update the current time every second
    property var currentTime: new Date()

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: window.currentTime = new Date()
    }

    // Centered Clock Display
    Column {
        anchors.centerIn: parent
        spacing: 4

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: window.currentTime.toLocaleTimeString(Qt.locale(), "hh:mm:ss AP")
            color: "#FFFFFF"
            font.pixelSize: 64
            font.weight: Font.Bold
            font.family: "Sans"
            
            // Subtle drop shadow for visibility against bright wallpapers
            style: Text.Outline
            styleColor: "#40000000"
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: window.currentTime.toLocaleDateString(Qt.locale(), "dddd, MMMM d, yyyy")
            color: "#D0D0D0"
            font.pixelSize: 20
            font.family: "Sans"
            
            style: Text.Outline
            styleColor: "#40000000"
        }
    }
}
