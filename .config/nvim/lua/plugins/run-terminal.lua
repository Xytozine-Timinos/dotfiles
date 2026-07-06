return {
	"akinsho/toggleterm.nvim",
	config = function()
		require("toggleterm").setup({
			start_in_insert = true,
			persist_mode = false,
		})
		vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter", "TermOpen" }, {
			pattern = "term://*",
			callback = function()
				vim.cmd("startinsert")
			end,
		})
	end,
}
