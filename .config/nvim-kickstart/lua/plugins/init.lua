-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

-- Iterate over all Lua files in this directory and load them.
local plugins_dir = vim.fs.joinpath(vim.fn.stdpath("config"), "lua", "plugins")
local plugin_modules = {}

for file_name, type in vim.fs.dir(plugins_dir) do
	if type == "file" and file_name:match("%.lua$") and file_name ~= "init.lua" then
		table.insert(plugin_modules, (file_name:gsub("%.lua$", "")))
	end
end

table.sort(plugin_modules)

for _, module in ipairs(plugin_modules) do
	require("plugins." .. module)
end
