-- Don't know why but if you enable powershell it crashes
return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	opts = {
		auto_install = true,
		-- event = { "BufRead", "BufNewFile" },
		ensure_installed = { "go", "c", "lua", "gomod", "gosum" },
		highlight = {
			enable = true,
			additional_vim_regex_highlighting = false,
		},
	},
	-- config = function(_, _)
	-- 	require("nvim-treesitter.configs").setup({
	-- 		sync_install = false,
	-- 		ignore_install = { "powershell" },
	-- 		modules = {},
	-- 		auto_install = true,
	-- 		ensure_installed = { "go", "c", "lua", "gomod", "gosum" },
	-- 		highlight = {
	-- 			enable = true,
	-- 			disable = { "powershell" },
	-- 			additional_vim_regex_highlighting = false,
	-- 		},
	-- 		indent = { enable = true },
	-- 	})
	-- end,
}
