require("config.lazy")
require("config.keymaps")
require("config.autocmds")
require("config.options")
require("config.lsp")
require("notify").setup({
  background_colour = function()
    local hl = vim.api.nvim_get_hl_by_name("Normal", true)
    if hl and hl.background then
      return string.format("#%06x", hl.background)
    end
    return "#000000"
  end,
})
