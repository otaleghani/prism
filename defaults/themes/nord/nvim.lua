-- Nord Configuration
local ok, nord = pcall(require, "nord")
if ok then
    -- shaunsingh/nord.nvim uses global variables for specific tweaks
    vim.g.nord_contrast = true
    vim.g.nord_borders = true
    vim.g.nord_disable_background = true -- Matches your Prism aesthetic
    vim.g.nord_italic = true

    vim.cmd.colorscheme("nord")
end
