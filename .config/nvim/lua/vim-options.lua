-- general configs and keybinds

-- variables
local o = vim.o
local g = vim.g
local km = vim.keymap

-- general config
g.mapleader = " "
g.termguicolors = true
o.mousemoveevent = true
o.number = true
o.updatetime = 555 -- miliseconds
o.relativenumber = false
o.ruler = true
o.cursorline = true
o.guifont = "Jetbrainsmono Nerd Font:h10"
o.mouse = "a"

g.goyo_width = 120

-- keybinds
km.set("n", "<C-Space>", "<Esc>", { noremap = true, silent = true })
km.set("i", "<C-Space>", "<Esc>", { noremap = true, silent = true })
km.set("v", "<C-Space>", "<Esc>", { noremap = true, silent = true })

km.set("n", "<leader>SO", "<cmd>source %<CR>")
km.set("n", "<leader>l", "<cmd>Lazy<CR>")
km.set("n", "<leader>m", "<cmd>Mason<CR>")
km.set("n", "<leader>ts", "<cmd> FineCmdline TSInstall <CR>")
km.set("n", "<leader>s", "<cmd>Store<CR>")

km.set("n", "<leader>th", ":ToggleTerm direction=horizontal<CR>", { noremap = true })
km.set("n", "<leader>tv", ":ToggleTerm direction=vertical<CR>", { noremap = true })

km.set("n", "<leader>[", "<cmd>FineCmdline split <CR>")
km.set("n", "<leader>]", "<cmd>FineCmdline vsplit <CR>")
km.set("n", "<leader>{", ":split #<CR>")
km.set("n", "<leader>}", ":vsplit #<CR>")

km.set("n", "<leader><bs>", "<cmd>:q<CR>")
km.set("n", "Q", "<cmd>:wq<CR>")
km.set("n", "qq", "<cmd>:q<CR>")
km.set("n", "ee", "<cmd>:w<CR>")
km.set("n", "<C-a>", "ggVG", { noremap = true, silent = true })

km.set("n", "<TAB>", "<Cmd>Neotree buffers toggle<CR>")

km.set("n", "<C-u>", "<Cmd>UndotreeToggle<CR>")

km.set("n", "<C-=>", "<cmd>:GUIFontSizeUp<CR>")
km.set("n", "<C-->", "<cmd>:GUIFontSizeDown<CR>")
km.set("n", "<C-0>", "<cmd>:GUIFontSizeSet<CR>")

km.set("n", "<C-e>", "<cmd>Neotree toggle<CR>")

km.set("n", ";", "<cmd>FineCmdline<CR>")
km.set("n", "/", ":SearchBoxMatchAll<CR>")

km.set("n", "<leader>db", ":DBUIToggle<CR>")

km.set("n", "<leader>/", function()
	require("Comment.api").toggle.linewise.current()
end, { desc = "comment toggle" })

km.set(
	"v",
	"<leader>/",
	"<ESC><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>",
	{ desc = "comment toggle" }
)
-- Keymap to view notification history
km.set("n", "<leader>nh", "<cmd>Telescope notify<CR>", { desc = "Notification history" })

km.set("n", "<leader>gf", vim.lsp.buf.format, {})

km.set("n", "<leader>gl", function()
	local lint = require("lint")
	lint.try_lint()
end, {})

km.set("n", "K", vim.lsp.buf.hover, {})
km.set("n", "<leader>ca", vim.lsp.buf.code_action, {})

km.set("n", "<leader><Tab>", "<cmd>Telescope buffers<CR>")
km.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>")
km.set("n", "<leader>fo", "<cmd>Telescope oldfiles<CR>")
km.set("n", "<leader>nf", "<cmd>lua require'startup'.new_file()<CR>")
km.set("n", "<leader>h", "<cmd>Telescope command_history<CR>")
km.set("n", "<leader>?", "<cmd>Telescope keymaps<CR>")

km.set("n", "w", "k", { noremap = true, silent = true })
km.set("n", "s", "j", { noremap = true, silent = true })
km.set("n", "a", "h", { noremap = true, silent = true })
km.set("n", "d", "l", { noremap = true, silent = true })
km.set("n", "<S-s>", "<PageDown>", { noremap = true, silent = true })
km.set("n", "<S-w>", "<PageUp>", { noremap = true, silent = true })
km.set("n", "<S-a>", "^", { noremap = true, silent = true })
km.set("n", "<S-d>", "$", { noremap = true, silent = true })

km.set("n", "<C-w>w", "<C-W>K", { noremap = true, silent = true })
km.set("n", "<C-w>s", "<C-W>J", { noremap = true, silent = true })
km.set("n", "<C-w>a", "<C-W>H", { noremap = true, silent = true })
km.set("n", "<C-w>d", "<C-W>L", { noremap = true, silent = true })

km.set("n", "<C-w><Up>", "<C-W>K", { noremap = true, silent = true })
km.set("n", "<C-w><Down>", "<C-W>J", { noremap = true, silent = true })
km.set("n", "<C-w><Left>", "<C-W>H", { noremap = true, silent = true })
km.set("n", "<C-w><Right>", "<C-W>L", { noremap = true, silent = true })

km.set("n", "h", "b", { noremap = true, silent = true })
km.set("n", "k", "a", { noremap = true, silent = true })
km.set("n", "j", "w", { noremap = true, silent = true })
km.set("n", "l", "a", { noremap = true, silent = true })

-- vim macro
km.set("n", "4", function()
	if vim.fn.reg_recording() == "" then
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("qq", true, true, true), "n", false)
	else
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("q", true, true, true), "n", false)
	end
end, { silent = true, desc = "Toggle Macro Recording (Register q)" })
km.set("n", "5", "@q", { remap = true, silent = true, desc = "Play Macro (Register q)" })

km.set("n", "2", "a", { noremap = true, silent = true })
km.set("n", "3", "dd", { noremap = true, silent = true })
km.set("v", "3", "dd", { noremap = true, silent = true })
km.set("n", "1", "d", { noremap = true, silent = true })
km.set("v", "1", "d", { noremap = true, silent = true })

km.set("v", "w", "k", { noremap = true, silent = true })
km.set("v", "s", "j", { noremap = true, silent = true })
km.set("v", "a", "h", { noremap = true, silent = true })
km.set("v", "d", "l", { noremap = true, silent = true })
km.set("v", "<S-s>", "<PageDown>", { noremap = true, silent = true })
km.set("v", "<S-w>", "<PageUp>", { noremap = true, silent = true })
km.set("v", "<S-a>", "^", { noremap = true, silent = true })
km.set("v", "<S-d>", "$", { noremap = true, silent = true })

local function get_run_command()
	local filetype = vim.bo.filetype
	local filename = vim.fn.expand("%:p")
	local filename_no_ext_no_path = vim.fn.expand("%:t:r")
	local temp_dir = vim.fn.stdpath("run") or "/tmp"
	local exe_out = temp_dir .. "/" .. filename_no_ext_no_path

	-- Map filetypes to their respective execution commands
	local commands = {
		c = "gcc " .. filename .. " -o " .. exe_out .. " && " .. exe_out,
		cpp = "g++ " .. filename .. " -o " .. exe_out .. " && " .. exe_out,
		java = "java " .. filename,
		python = "python3 " .. filename,
		javascript = "node " .. filename,
		typescript = "ts-node " .. filename,
		go = "go run " .. filename,
		rust = "cargo run",
		sh = "bash " .. filename,
		html = "xdg-open " .. filename,
		lua = "lua " .. filename,
	}

	return commands[filetype]
end

_G.run_code = function()
	local cmd = get_run_command()

	if cmd then
		require("toggleterm").exec(cmd, 9)
	else
		vim.notify("No run command configured for filetype: " .. vim.bo.filetype, vim.log.levels.WARN)
	end
end

km.set("n", "<F1>", _G.run_code, { noremap = true })
