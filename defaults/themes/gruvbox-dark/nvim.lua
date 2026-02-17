-- Gruvbox Configuration
local ok, gruvbox = pcall(require, "gruvbox")
if ok then
    gruvbox.setup({
        contrast = "hard",
        transparent_mode = true,
    })
    vim.cmd("colorscheme gruvbox")
end
