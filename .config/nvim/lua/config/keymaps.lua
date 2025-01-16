-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Don't leave visual mode when changing indent
vim.api.nvim_set_keymap("x", ">", ">gv", { noremap = true })
vim.api.nvim_set_keymap("x", "<", "<gv", { noremap = true })

vim.api.nvim_set_keymap("n", "<leader>tw", ":Twilight<CR>", { noremap = true })

-- Insert mode mappings
vim.api.nvim_set_keymap("i", "<C-h>", "<Left>", {})
vim.api.nvim_set_keymap("i", "<C-j>", "<Down>", {})
vim.api.nvim_set_keymap("i", "<C-k>", "<Up>", {})
vim.api.nvim_set_keymap("i", "<C-l>", "<Right>", {})

-- Select all
vim.api.nvim_set_keymap("i", "<C-a>", "<C-c>ggVG", {})
vim.api.nvim_set_keymap("n", "<C-a>", "ggVG", {})
