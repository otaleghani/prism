return {
	"stevearc/oil.nvim",
	---@module 'oil'
	---@type oil.SetupOpts
	opts = {},
	-- Optional dependencies
	dependencies = { "nvim-tree/nvim-web-devicons" },
	lazy = false,
	keys = {
		{
			"<leader>fm",
			"<cmd>Oil<CR>",
			desc = "Open oil in current directory",
		},
	},
}
