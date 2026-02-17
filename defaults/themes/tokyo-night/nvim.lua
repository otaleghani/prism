-- Tokyo Night Configuration
-- The setup call is handled by 'opts' in the lazy config above, 
-- but you can also do it manually here:
require("tokyonight").setup({
  style = "moon",
  transparent = true,
  terminal_colors = true,
  styles = {
    comments = { italic = true },
    keywords = { italic = true },
    sidebars = "dark", 
    floats = "dark",
  },
})

-- Apply the colorscheme
pcall(vim.cmd.colorscheme, "tokyonight")
