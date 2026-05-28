-- [[ Colorscheme ]]
-- you can easily change to a different colorscheme.
-- Change the name of the colorscheme plugin below, and then
-- change the command under that to load whatever the name of that colorscheme is.
--
-- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
vim.pack.add({ "https://github.com/Mofiqul/vscode.nvim" })
require("vscode").setup()
vim.cmd.colorscheme("vscode")

-- Fundo transparente (herda do terminal)
local function set_transparent()
	vim.api.nvim_set_hl(0, "Normal", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "NonText", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "SignColumn", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "LineNr", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "StatusLine", { bg = "NONE" })
	vim.api.nvim_set_hl(0, "TabLineFill", { bg = "NONE" })
end

vim.api.nvim_create_autocmd("ColorScheme", {
	callback = set_transparent,
})

set_transparent()
