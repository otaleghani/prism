return {
	cmd = { "qmlls" },

	filetypes = { "qml", "qmljs" },

	-- Root detection: Look for git, flake.nix, or the qmldir definition
	root_markers = {
		".git",
		"flake.nix",
		"qmldir",
	},

	single_file_support = true,

	-- Settings specific to qmlls (usually empty is fine, but can be tweaked)
	settings = {},
}
