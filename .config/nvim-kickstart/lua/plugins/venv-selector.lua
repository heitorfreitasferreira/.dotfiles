vim.pack.add({ "https://github.com/linux-cultist/venv-selector.nvim" })

require("venv-selector").setup({
	options = {
		notify_user_on_venv_activation = true,
		override_notify = false,
	},
})

