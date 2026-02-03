return {
	cmd = { "vscode-html-language-server", "--stdio" },
	filetypes = { "html", "css", "scss", "less", "json" },
	root_markers = { ".git", "package.json" },
	settings = {},
	capabilities = vim.tbl_deep_extend("force", vim.lsp.protocol.make_client_capabilities(), {
		textDocument = {
			completion = {
				completionItem = {
					snippetSupport = true,
				},
			},
		},
	}),
	settings = {},
}
