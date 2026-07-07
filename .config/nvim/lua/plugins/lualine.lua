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
				globalstatus = true,
				refresh = {
					statusline = 100,
					tabline = 100,
					winbar = 100,
				},
			},

			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = {
					{
						function()
							local path_opt = 1 -- 0: Just filename, 1: Relative path, 2: Absolute path
							local name = ""
							if path_opt == 1 then
								name = vim.fn.expand("%:~:.") -- Relative path
							elseif path_opt == 2 then
								name = vim.fn.expand("%:p") -- Absolute path
							else
								name = vim.fn.expand("%:t") -- Filename only
							end
							if name == "" then
								name = "[No Name]"
							end

							local has_devicons, devicons = pcall(require, "nvim-web-devicons")
							local icon = ""
							if has_devicons then
								local f_name = vim.fn.expand("%:t")
								local f_ext = vim.fn.expand("%:e")
								local dev_icon, dev_icon_hi = devicons.get_icon(f_name, f_ext, { default = true })
								if dev_icon then
									icon = string.format("%%#%s#%s%%* ", dev_icon_hi, dev_icon)
								end
							end

							local modified_sym = " %#DiagnosticWarn#󰷫%*"
							local readonly_sym = " %#DiagnosticError#%*"
							local newfile_sym = " %#DiagnosticInfo#[New]%*"

							if vim.bo.modified then
								return icon .. "%#DiagnosticWarn#" .. name .. "%*" .. modified_sym
							elseif vim.bo.readonly or not vim.bo.modifiable then
								return icon .. "%#DiagnosticError#" .. name .. "%*" .. readonly_sym
							elseif vim.fn.filereadable(vim.fn.expand("%:p")) == 0 and name ~= "[No Name]" then
								return icon .. "%#DiagnosticInfo#" .. name .. "%*" .. newfile_sym
							else
								return icon .. name
							end
						end,
						file_status = false,
					},
				},
				lualine_x = {
					"encoding",
					"fileformat",
					"filetype",
				},
				lualine_y = { "progress", "location" },
				lualine_z = {
					{
						function()
							return "󰥔 " .. os.date("%I:%M %p")
						end,
						-- color = { fg = "#81ccee", gui = "bold" },
					},
				},
			},
			tabline = {
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
							return " New"
						end,
						color = { fg = "#81ccee", gui = "bold" },
						on_click = function()
							vim.cmd("lua require'startup'.new_file()")
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
								elseif choice == " Cancel" then
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
				lualine_c = {},
				lualine_x = {},
				lualine_y = {},
				lualine_z = {},
			},
			inactive_winbar = {},
			extensions = {},
		})
	end,
}
