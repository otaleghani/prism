local map = vim.keymap.set
local opts = { noremap = true, silent = true }

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Basic keymaps
map("n", "<leader>w", "<Cmd>write<cr>", opts) -- Save file
map("n", "<leader>q", "<Cmd>quit<cr>", opts) -- Quit
map("n", "<leader>o", "<Cmd>source<cr>", opts) -- Update config
-- map("n", "<leader>f", "<Cmd>lua vim.lsp.buf.format()<cr>", opts) -- Update config

-- Splitting windows
vim.o.splitright = true
vim.o.splitbelow = true
map("n", "<leader>wl", "<Cmd>vsplit<CR>", { desc = "Split window right" })
map("n", "<leader>wj", "<Cmd>split<CR>", { desc = "Split window down" })
map("n", "<leader>wh", "<Cmd>leftabove vsplit<CR>", { desc = "Split window left" })
map("n", "<leader>wk", "<Cmd>aboveleft split<CR>", { desc = "Split window up" })
map("n", "<leader>wL", "<Cmd>vnew<CR>", { desc = "New buffer window right" })
map("n", "<leader>wJ", "<Cmd>new<CR>", { desc = "New buffer window down" })
map("n", "<leader>wH", "<Cmd>leftabove vnew<CR>", { desc = "New buffer window left" })
map("n", "<leader>wK", "<Cmd>aboveleft new<CR>", { desc = "New buffer window up" })

-- Window movement
map("n", "<leader>h", "<C-w>h", { desc = "Go to left window" })
map("n", "<leader>j", "<C-w>j", { desc = "Go to lower window" })
map("n", "<leader>k", "<C-w>k", { desc = "Go to upper window" })
map("n", "<leader>l", "<C-w>l", { desc = "Go to right window" })

map("n", "<leader>wq", "<Cmd>close<CR>", { desc = "Close current window" })
map("n", "<leader>bq", "<Cmd>bdelete<CR>", { desc = "Close current buffer" })
map("n", "<leader>bQ", "<Cmd>bdelete!<CR>", { desc = "Force close current buffer" })

-- LSP diagnostic
map("n", "<leader>d", "<Cmd>lua vim.diagnostic.open_float()<CR>", opts)

-- Golang if err != nil
map("n", "<leader>ie", "oif err != nil {\n\treturn err\n}<esc>o", {
	noremap = true,
	silent = true,
	desc = "Insert Go if err != nil block",
})

-- Restart lsp client
vim.keymap.set("n", "<leader>rl", function()
	vim.lsp.stop_client(vim.lsp.get_clients())
	vim.cmd("edit")
end, { noremap = true, silent = true, desc = "Restart LSP & Reload File" })
