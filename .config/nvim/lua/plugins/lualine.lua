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
				component_separators = { left = "", right = "" },
				section_separators = { left = " ", right = " " },
				disabled_filetypes = {
					statusline = {
						"NvimTree",
						"neo-tree",
						"toggleterm",
						"startup",
						"dapui_scopes",
						"dapui_breakpoints",
						"dapui_stacks",
						"dapui_watches",
						"dapui_console",
						"dap-repl",
					},
					winbar = {
						"NvimTree",
						"neo-tree",
						"toggleterm",
						"startup",
						"dapui_scopes",
						"dapui_breakpoints",
						"dapui_stacks",
						"dapui_watches",
						"dapui_console",
						"dap-repl",
					},
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
						path = 1,
						symbols = { modified = "󰷫 ", readonly = " ", unnamed = "[No Name]", newfile = "[New]" },
					},
				},
				lualine_x = {
					"encoding",
					"fileformat",
					"filetype",
				},
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
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
								{ "󰸧 Save and Quit", "󱙃 Quit Without Saving", " Cancel" },
								{ prompt = "Unsaved changes detected:" },
								function(choice)
									if choice == "󰸧 Save and Quit" then
										vim.cmd("wq")
									elseif choice == "󱙃 Quit Without Saving" then
										vim.cmd("q!")
									end
								end
							)
						end,
					},
					{
						function()
							return "󰈞 Open"
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
					{
						function()
							return "%="
						end,
						separator = "",
						padding = 0,
					},
					{
						function()
							return " Neotree"
						end,
						color = { fg = "#81ccee", gui = "bold" },
						on_click = function()
							vim.cmd("Neotree toggle")
						end,
					},
					{
						function()
							return "󰉢 Format"
						end,
						color = { fg = "#81ccee", gui = "bold" },
						on_click = function()
							local clients = vim.lsp.get_clients({ bufnr = 0 })
							if #clients == 0 then
								vim.notify("No active LSP formatter available!", vim.log.levels.WARN)
								return
							end
							vim.lsp.buf.format({ async = true })
						end,
					},
					{
						function()
							return " Undotree"
						end,
						color = { fg = "#81ccee", gui = "bold" },
						on_click = function()
							vim.cmd("UndotreeToggle")
						end,
					},
				},
				lualine_x = {
					{
						function()
							return "Time: " .. os.date("%I:%M %p")
						end,
						color = { fg = "#81ccee", gui = "bold" },
						on_click = function()
							os.execute("~/.config/rofi/modules/rofi-calendar")
						end,
					},
					{
						function()
							return " Run"
						end,
						color = { fg = "#a6e3a1", gui = "bold" },
						on_click = function()
							_G.lualine_run_code()
						end,
					},
					{
						function()
							local dapui = package.loaded["dapui"]
							if dapui and dapui.visible and dapui.visible() then
								return " Close Debug"
							end
							return " Debug"
						end,
						color = { fg = "#f9e2af", gui = "bold" },
						on_click = function()
							local ok, dapui = pcall(require, "dapui")
							if ok then
								dapui.toggle()
							else
								vim.notify("dap-ui is not loaded yet!", vim.log.levels.WARN)
							end
						end,
					},
					{
						function()
							return " Terminal"
						end,
						color = { fg = "#eba0ac", gui = "bold" },
						on_click = function()
							local layout_options = { "Horizontal", "Vertical", "Float", " Cancel" }

							vim.ui.select(layout_options, {
								prompt = "Select Terminal Layout:",
							}, function(choice)
								if not choice then
									return
								end

								local direction = choice:lower()
								local cmd = "ToggleTerm direction=" .. direction
								if direction == "vertical" then
									local one_third_width = math.floor(vim.o.columns / 3)
									cmd = cmd .. " size=" .. one_third_width
								end

								vim.cmd(cmd)
							end)
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
