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
		"mfussenegger/nvim-jdtls",
		ft = "java",
	},
}
