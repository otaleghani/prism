return {
	cmd = { "vscode-json-language-server", "--stdio" }, -- Changed from html to json
	filetypes = { "json", "jsonc" }, -- Added jsonc for files with comments
	root_markers = { ".git", "package.json" },
	init_options = {
		provideFormatter = true,
	},
	capabilities = vim.tbl_deep_extend("force", vim.lsp.protocol.make_client_capabilities(), {
		textDocument = {
			completion = {
				completionItem = {
					snippetSupport = true,
				},
			},
		},
	}),
}
