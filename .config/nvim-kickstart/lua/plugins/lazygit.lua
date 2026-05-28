vim.pack.add({
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/kdheepak/lazygit.nvim",
})

local function setup_lazygit_editor()
	local server = vim.v.servername
	if server == "" then
		return
	end

	vim.env.NVIM = server
	vim.env.NVIM_LISTEN_ADDRESS = server

	local config_path = vim.fn.stdpath("cache") .. "/lazygit-nvim.yml"
	local edit_command = ('nvim --server %q --remote-tab "{{filename}}"'):format(server)
	vim.fn.writefile({
		"os:",
		"  editCommand: nvim",
		"  editCommandTemplate: " .. string.format("%q", edit_command),
		"  openCommand: " .. string.format("%q", edit_command),
	}, config_path)

	local config_files = {}
	for file in string.gmatch(vim.env.LG_CONFIG_FILE or "", "[^,]+") do
		if file ~= "" then
			table.insert(config_files, file)
		end
	end

	local out = vim.fn.system({ "lazygit", "-cd" })
	if vim.v.shell_error == 0 then
		local config_dir = vim.split(out, "\n", { plain = true })[1]
		local default_config = config_dir .. "/config.yml"
		if vim.uv.fs_stat(default_config) and not vim.tbl_contains(config_files, default_config) then
			table.insert(config_files, default_config)
		end
	end

	if not vim.tbl_contains(config_files, config_path) then
		table.insert(config_files, config_path)
	end
	vim.env.LG_CONFIG_FILE = table.concat(config_files, ",")
end

setup_lazygit_editor()

vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "Git: LazyGit" })
