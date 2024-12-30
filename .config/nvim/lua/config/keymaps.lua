-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Comment
vim.keymap.set("n", "<C-_>", function()
  require("Comment.api").toggle.linewise.current()
end, { noremap = true, silent = true })

-- Don't leave visual mode when changing indent
vim.api.nvim_set_keymap("x", ">", ">gv", { noremap = true })
vim.api.nvim_set_keymap("x", "<", "<gv", { noremap = true })
