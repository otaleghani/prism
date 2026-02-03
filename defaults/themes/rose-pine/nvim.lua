-- Rose Pine Configuration
local status, rosepine = pcall(require, "rose-pine")
if status then
	rosepine.setup({
		variant = "main", -- auto, main, moon, dawn
		dark_variant = "main",
		dim_inactive_windows = false,
		extend_background_behind_borders = true,

		styles = {
			bold = true,
			italic = true,
			transparency = true, -- Matches Prism aesthetic
		},
	})
	vim.cmd.colorscheme("rose-pine")
end
