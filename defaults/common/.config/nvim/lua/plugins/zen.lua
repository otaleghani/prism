return {
	"folke/zen-mode.nvim",
	opts = {
		plugins = {
			tmux = { enabled = false },
		},
	},
	keys = {
		{
			"<leader>z",
			"<cmd>ZenMode<cr>",
			desc = "Toggle zen mode",
		},
	},
}
