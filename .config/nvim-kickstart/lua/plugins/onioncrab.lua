vim.pack.add({
	{ src = "https://github.com/ThePrimeagen/harpoon", version = "harpoon2" },
	{ src = "/home/heitor/onioncrab.nvim", name = "onioncrab.nvim" },
})

require("onioncrab").setup()

vim.keymap.set("n", "<leader>oa", function()
	require("onioncrab").add()
end, { desc = "Onioncrab: Add" })

vim.keymap.set("n", "<leader>om", function()
	require("onioncrab").menu()
end, { desc = "Onioncrab: Menu" })

vim.keymap.set("n", "<leader>oo", function()
	require("onioncrab").open()
end, { desc = "Onioncrab: Open" })

vim.keymap.set("n", "<leader>oh", function()
	require("onioncrab").left()
end, { desc = "Onioncrab: Left" })

vim.keymap.set("n", "<leader>ol", function()
	require("onioncrab").right()
end, { desc = "Onioncrab: Right" })

vim.keymap.set("n", "<leader>ok", function()
	require("onioncrab").up()
end, { desc = "Onioncrab: Up" })

vim.keymap.set("n", "<leader>oj", function()
	require("onioncrab").down()
end, { desc = "Onioncrab: Down" })
