vim.pack.add({ "https://github.com/folke/sidekick.nvim" })

require("sidekick").setup({
	nes = {
		debounce = 500,
	},
	copilot = {
		status = {
			level = vim.log.levels.OFF,
		},
	},
	cli = {
		mux = {
			backend = "tmux",
			enabled = true,
		},
	},
})

vim.keymap.set("i", "<Tab>", function()
	if require("sidekick").nes_jump_or_apply() then
		return ""
	end

	return "<Tab>"
end, { expr = true, desc = "Goto/Apply Next Edit Suggestion" })

vim.keymap.set({ "n", "t", "i", "x" }, "<C-.>", function()
	require("sidekick.cli").toggle()
end, { desc = "Sidekick Toggle" })

vim.keymap.set("n", "<leader>aa", function()
	require("sidekick.cli").toggle({ name = "cursor", focus = true })
end, { desc = "Sidekick Toggle CLI" })

vim.keymap.set("n", "<leader>as", function()
	require("sidekick.cli").select({ filter = { installed = true } })
end, { desc = "Select CLI" })

vim.keymap.set({ "x", "n" }, "<leader>at", function()
	require("sidekick.cli").send({ msg = "{this}", name = "cursor", focus = true })
end, { desc = "Send This" })

vim.keymap.set("n", "<leader>af", function()
	require("sidekick.cli").send({ msg = "{file}", name = "cursor", focus = true })
end, { desc = "Send File" })

vim.keymap.set("x", "<leader>av", function()
	require("sidekick.cli").send({ msg = "{selection}", name = "cursor", focus = true })
end, { desc = "Send Visual Selection" })

vim.keymap.set({ "n", "x" }, "<leader>ap", function()
	require("sidekick.cli").prompt({ name = "cursor", focus = true })
end, { desc = "Sidekick Select Prompt" })
