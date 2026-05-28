-- Oil lets you edit directories like regular buffers.
-- https://github.com/stevearc/oil.nvim

local plugins = {
	"https://github.com/stevearc/oil.nvim",
}

if vim.g.have_nerd_font then
	table.insert(plugins, "https://github.com/nvim-tree/nvim-web-devicons") -- not strictly required, but recommended
end

vim.pack.add(plugins)

vim.keymap.set("n", "\\", "<Cmd>Oil<CR>", { desc = "Open parent directory", silent = true })

require("oil").setup({
	default_file_explorer = true,
	columns = vim.g.have_nerd_font and { "icon" } or {},
	keymaps = {
		["\\"] = "actions.close",
	},
})
