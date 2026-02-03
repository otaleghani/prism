-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- --- PRISM THEME LOADER ---
-- We wrap this in a pcall to prevent errors during first install
local function load_prism_theme()
	local prism_theme_path = vim.fn.expand("~/.local/share/prism/current/nvim.lua")
	if vim.fn.filereadable(prism_theme_path) == 1 then
		dofile(prism_theme_path)
	end
end

-- Load immediately if possible, or wait for UI enter
load_prism_theme()

-- Optional: Add a watcher if you want hot-reloading without restarting nvim
-- (This requires the file to be touched/changed)
vim.api.nvim_create_autocmd("FocusGained", {
	callback = load_prism_theme,
})
