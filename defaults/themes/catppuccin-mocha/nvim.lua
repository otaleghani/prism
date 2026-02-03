-- Catppuccin Mocha Configuration
local status, catppuccin = pcall(require, "catppuccin")
if status then
	catppuccin.setup({
		flavour = "mocha", -- latte, frappe, macchiato, mocha
		transparent_background = true,
		term_colors = true,
		integrations = {
			cmp = true,
			gitsigns = true,
			nvimtree = true,
			treesitter = true,
			notify = false,
			mini = {
				enabled = true,
				indentscope_color = "",
			},
		},
	})
	vim.cmd.colorscheme("catppuccin")
end
