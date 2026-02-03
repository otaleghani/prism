-- Everforest Dark Hard Configuration
-- Everforest uses global variables for configuration
vim.g.everforest_background = "hard"
vim.g.everforest_enable_italic = 1
vim.g.everforest_transparent_background = 1 -- Matches Prism aesthetic
vim.g.everforest_ui_contrast = "high"

-- Apply the colorscheme
-- We wrap in pcall just in case the plugin isn't loaded yet
pcall(vim.cmd.colorscheme, "everforest")
