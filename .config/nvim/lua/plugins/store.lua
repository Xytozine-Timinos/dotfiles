return {
	"alex-popov-tech/store.nvim",
	dependencies = { "OXY2DEV/markview.nvim" },
	cmd = "Store",
	enabled = false,
	config = function()
		require("store").setup({})
	end,
}
