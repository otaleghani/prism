local function get_tsserver_path(root_dir)
	-- 1. Try local node_modules (Standard)
	local node_modules = vim.fs.find("node_modules", { path = root_dir, upward = true })[1]
	if node_modules then
		local path = vim.fs.joinpath(vim.fs.dirname(node_modules), "node_modules", "typescript", "lib")
		if vim.uv.fs_stat(vim.fs.joinpath(path, "typescript.js")) then
			return path
		end
	end

	-- 2. NixOS Fallback: Search the system/shell PATH for tsserver
	-- This works if 'typescript' or 'nodePackages.typescript' is in your Nix config/shell
	local tsserver_bin = vim.fn.exepath("tsserver")
	if tsserver_bin ~= "" then
		-- Follow symlink to the Nix store and go up to the lib directory
		local real_path = vim.fn.resolve(tsserver_bin)
		local lib_path = vim.fs.joinpath(vim.fs.dirname(real_path), "..", "lib", "node_modules", "typescript", "lib")
		if vim.uv.fs_stat(vim.fs.joinpath(lib_path, "typescript.js")) then
			return lib_path
		end
	end

	return nil
end

return {
	cmd = { "astro-ls", "--stdio" },
	filetypes = { "astro" },
	root_markers = { "package.json", "astro.config.mjs", ".git" },
	init_options = {
		typescript = {},
	},
	before_init = function(_, config)
		local tsdk = get_tsserver_path(config.root_dir)
		if tsdk then
			config.init_options.typescript.tsdk = tsdk
		else
			-- If we reach here, the LSP will fail.
			-- Print a message to help you debug why it's missing.
			vim.notify("Astro LSP: Could not find typescript.js in node_modules or PATH", vim.log.levels.WARN)
		end
	end,
	-- Your existing capabilities...
}
