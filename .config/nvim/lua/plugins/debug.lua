return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui",
			"nvim-neotest/nvim-nio",
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			-- bash debugger
			dap.adapters.bashdb = {
				type = "executable",
				command = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/bash-debug-adapter",
				name = "bashdb",
			}

			dap.configurations.sh = {
				{
					type = "bashdb",
					request = "launch",
					name = "Launch file",
					showDebugOutput = true,
					trace = true,
					-- Paths to bashdb components (adjust if installed manually)
					pathBashdb = vim.fn.stdpath("data")
						.. "/mason/packages/bash-debug-adapter/extension/bashdb_dir/bashdb",
					pathBashdbLib = vim.fn.stdpath("data") .. "/mason/packages/bash-debug-adapter/extension/bashdb_dir",
					file = "${file}",
					program = "${file}",
					cwd = "${workspaceFolder}",
					pathCat = "cat",
					pathBash = "/bin/bash",
					pathMkfifo = "mkfifo",
					pathPkill = "pkill",
					args = {},
					env = {},
					terminalKind = "integrated",
				},
			}
			-- end of bash debugger

			dapui.setup()

			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				dapui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end

			vim.keymap.set("n", "<F5>", dap.continue, { desc = "Debug: Start/Continue" })
			vim.keymap.set("n", "<F6>", dap.step_into, { desc = "Debug: Step Into" })
			vim.keymap.set("n", "<F7>", dap.step_over, { desc = "Debug: Step Over" })
			vim.keymap.set("n", "<F8>", dap.step_out, { desc = "Debug: Step Out" })
			vim.keymap.set("n", "B", dap.toggle_breakpoint, { desc = "Debug: Toggle Breakpoint" })
		end,
	},
	{
		"theHamsta/nvim-dap-virtual-text",
		dependencies = { "mfussenegger/nvim-dap" },
	},
	{
		"williamboman/mason-nvim-dap.nvim",
	},
	{
		"mfussenegger/nvim-jdtls",
	},
}
