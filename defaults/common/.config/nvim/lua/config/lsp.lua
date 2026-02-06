vim.lsp.enable({
	"clangd",
	"lua_ls",
	"qmlls",
	"gopls",
	"nil",
	"bash-language-server",
	"templ",
	"tailwind",
	"typescript-language-server",
	"vscode",
	"vscode-json",
	"astro",
})

-- Diagnostics
vim.diagnostic.config({
	virtual_text = false,
	virtual_lines = true,
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	float = {
		header = false,
		border = "rounded",
		source = true,
	},
})
