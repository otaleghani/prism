return {
	"stevearc/conform.nvim",
	opts = {},
	config = function()
		require("conform").setup({
			formatters_by_ft = {
				c = { "clang-format" },
				cpp = { "clang-format" },
				objc = { "clang-format" },
				lua = { "stylua" },
				go = { "goimports", "golines", "gofmt" },
				templ = { "templ" },
				markdown = { "mdformat" },
				nix = { "nixfmt" },
				sh = { "shfmt" },
				templ = { "templ" },
				typescriptreact = { "prettier" },
				typescript = { "prettier" },
				javascriptreact = { "prettier" },
				javascript = { "prettier" },
				css = { "prettier" },
				gotmpl = { "djlint" },
				html = { "prettier" },
				astro = { "prettier" },
			},
			format_on_save = {
				lsp_fallback = true,
				async = false,
			},
		})
	end,
}
