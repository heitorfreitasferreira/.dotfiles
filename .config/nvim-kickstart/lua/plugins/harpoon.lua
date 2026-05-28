vim.pack.add({
	"https://github.com/nvim-lua/plenary.nvim",
	{ src = "https://github.com/ThePrimeagen/harpoon", version = "harpoon2" },
})

local harpoon = require("harpoon")

harpoon:setup({
	menu = {
		width = vim.api.nvim_win_get_width(0) - 4,
	},
	settings = {
		save_on_toggle = true,
	},
})

vim.keymap.set("n", "<leader>ha", function()
	harpoon:list():add()
end, { desc = "Harpoon File" })

vim.keymap.set("n", "<leader>hh", function()
	harpoon.ui:toggle_quick_menu(harpoon:list())
end, { desc = "Harpoon Quick Menu" })

vim.keymap.set("n", "<leader>hda", function()
	harpoon:list():clear()
end, { desc = "Harpoon clear all" })

for i = 1, 5 do
	vim.keymap.set("n", "<leader>" .. i, function()
		harpoon:list():select(i)
	end, { desc = "Harpoon to File " .. i })

	vim.keymap.set("n", "<leader>hd" .. i, function()
		harpoon:list():remove_at(i)
	end, { desc = "Harpoon remove index " .. i })
end
