return {
	"nvim-treesitter/nvim-treesitter",
	commit = "main",
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter").setup({
			ensure_installed = { "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline" },
			auto_install = true,
			highlight = { enable = true },
			indent = { enable = true },
		})
	end,
}
