return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.8",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	},
	keys = {
		{
			"<leader><space>",
			function()
				require("telescope.builtin").find_files()
			end,
			mode = "n",
			desc = "Find files (Root dir)",
		},
		{
			"<leader>/",
			function()
				require("telescope.builtin").live_grep()
			end,
			mode = "n",
			desc = "Live grep",
		},
		{
			"<leader>bb",
			function()
				require("telescope.builtin").buffers()
			end,
			mode = "n",
			desc = "Find open buffers",
		},
		{
			"<leader>s",
			function()
				require("telescope.builtin").lsp_document_symbols()
			end,
			mode = "n",
			desc = "Find document symbols",
		},
		{
			"<leader>S",
			function()
				require("telescope.builtin").lsp_workspace_symbols()
			end,
			mode = "n",
			desc = "Find project symbols",
		},
		{
			"<leader>D",
			function()
				require("telescope.builtin").diagnostics({ bufnr = 0 })
			end,
			mode = "n",
			desc = "Find diagnostics in current buffer",
		},
		-- {
		-- 	"<leader>D",
		-- 	function()
		-- 		require("telescope.builtin").diagnostics()
		-- 	end,
		-- 	mode = "n",
		-- 	desc = "Find diagnostics",
		-- },
	},
	config = function()
		require("telescope").setup({
			pickers = {
				find_files = {
					theme = "ivy",
					hidden = "true",
				},
				live_grep = {
					theme = "ivy",
					hidden = "true",
				},
				buffers = {
					theme = "ivy",
					hidden = "true",
				},
				lsp_document_symbols = {
					theme = "ivy",
					hidden = "true",
				},
				lsp_workspace_symbols = {
					theme = "ivy",
					hidden = "true",
				},
				diagnostics = {
					theme = "ivy",
					hidden = "true",
				},
			},
			extensions = {
				fzf = {},
			},
		})
	end,
}
