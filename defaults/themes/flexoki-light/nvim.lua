-- Flexoki Light Configuration
local ok, _ = pcall(require, "flexoki")
if ok then
    vim.opt.background = "light"
    pcall(vim.cmd.colorscheme, "flexoki")
end
