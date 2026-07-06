return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local function get_run_command()
			local filetype = vim.bo.filetype
			local filename = vim.fn.expand("%:p")
			local filename_no_ext_no_path = vim.fn.expand("%:t:r")
			local temp_dir = vim.fn.stdpath("run") or "/tmp"
			local exe_out = temp_dir .. "/" .. filename_no_ext_no_path

			-- Map filetypes to their respective execution commands
			local commands = {
				c = "gcc " .. filename .. " -o " .. exe_out .. " && " .. exe_out,
				cpp = "g++ -std=c++17 " .. filename .. " -o " .. exe_out .. " && " .. exe_out,
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

		_G.lualine_run_code = function()
			local cmd = get_run_command()

			if cmd then
				require("toggleterm").exec(cmd, 9)
			else
				vim.notify("No run command configured for filetype: " .. vim.bo.filetype, vim.log.levels.WARN)
			end
		end

		require("lualine").setup({
			options = {
				icons_enabled = true,
				theme = "auto",
				component_separators = { left = "", right = "" },
				section_separators = { left = " ", right = " " },
				disabled_filetypes = {
					statusline = { "NvimTree", "neo-tree", "toggleterm" },
					winbar = { "NvimTree", "neo-tree", "toggleterm", "startup" }, -- Keeps top bar out of popups/sidebars
				},
				ignore_focus = {},
				always_divide_middle = true,
				always_show_tabline = true,
				globalstatus = false,
				refresh = {
					statusline = 100,
					tabline = 100,
					winbar = 100,
				},
			},
			-- BOTTOM STATUSLINE (Now clean and tidy)
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = {
					{
						"filename",
						file_status = true,
						path = 1, -- Shortened path to save space
						symbols = { modified = "󰷫 ", readonly = " ", unnamed = "[No Name]", newfile = "[New]" },
					},
				},
				lualine_x = { "encoding", "fileformat", "filetype" }, -- Run button removed from here
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
			-- NEW: TOP BAR (Winbar) Configuration
			winbar = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = {
					{
						function()
							return "󰈆 Quit"
						end,
						color = { fg = "#ff6f91", gui = "bold" },
						on_click = function()
							if not vim.bo.modified then
								vim.cmd("q")
								return
							end

							vim.ui.select(
								{ "Save and Quit", "Quit Without Saving", "Cancel" },
								{ prompt = "Unsaved changes detected:" },
								function(choice)
									if choice == "Save and Quit" then
										vim.cmd("wq")
									elseif choice == "Quit Without Saving" then
										vim.cmd("q!")
									end
								end
							)
						end,
					},
					{
						function()
							return "󰳻 Open"
						end,
						color = { fg = "#81ccee", gui = "bold" },
						on_click = function()
							vim.cmd("Telescope oldfiles")
						end,
					},
					{
						function()
							return "󰳻 Save"
						end,
						color = { fg = "#81ccee", gui = "bold" },
						on_click = function()
							vim.cmd("w")
						end,
					},
				},
				lualine_x = {
					{
						function()
							return " Run Code"
						end,
						color = { fg = "#a6e3a1", gui = "bold" },
						on_click = function()
							_G.lualine_run_code()
						end,
					},
					{
						function()
							return " Open Terminal"
						end,
						color = { fg = "#eba0ac", gui = "bold" },
						on_click = function()
							vim.cmd("ToggleTerm direction=horizontal")
						end,
					},
				},
				lualine_y = {},
				lualine_z = {},
			},
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = { "filename" },
				lualine_x = { "location" },
				lualine_y = {},
				lualine_z = {},
			},
			inactive_winbar = {},
			tabline = {},
			extensions = {},
		})
	end,
}
