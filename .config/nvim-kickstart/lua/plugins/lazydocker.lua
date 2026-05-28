vim.pack.add({ "https://github.com/crnvl96/lazydocker.nvim" })

require("lazydocker").setup({
	window = {
		settings = {
			width = 0.8,
			height = 0.8,
			border = "rounded",
			relative = "editor",
		},
	},
})

vim.keymap.set({ "n", "t" }, "<leader>dd", function()
	require("lazydocker").toggle()
end, { desc = "Toggle LazyDocker" })
