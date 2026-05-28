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

local function refresh_git_status(bufnr)
	local buf_dir = vim.api.nvim_buf_get_name(bufnr):gsub("^oil://", ""):gsub("/$", "")
	local ok, lines = pcall(vim.fn.systemlist,
		"git -C " .. vim.fn.shellescape(buf_dir) .. " status --porcelain 2>/dev/null"
	)
	if not ok then
		vim.b[bufnr].oil_git_status = {}
		return
	end
	local root = vim.fn.systemlist(
		"git -C " .. vim.fn.shellescape(buf_dir) .. " rev-parse --show-toplevel 2>/dev/null"
	)[1]
	local prefix = ""
	if root then
		local rel = buf_dir:sub(#root + 2)
		if rel ~= "" then
			prefix = rel .. "/"
		end
	end
	local status_map = {}
	for _, line in ipairs(lines) do
		local s = line:sub(1, 2)
		local f = line:sub(4)
		if f:sub(1, #prefix) == prefix then
			local name = f:sub(#prefix + 1)
			local slash = name:find("/")
			if slash then
				name = name:sub(1, slash - 1)
			end
			if status_map[name] == nil then
				status_map[name] = s
			end
		end
	end
	vim.b[bufnr].oil_git_status = status_map
end

local aug = vim.api.nvim_create_augroup("OilCustom", { clear = true })
vim.api.nvim_create_autocmd("BufEnter", {
	group = aug,
	pattern = "oil://*",
	callback = function(args)
		vim.schedule(function()
			if vim.api.nvim_buf_is_valid(args.buf) then
				refresh_git_status(args.buf)
			end
		end)
	end,
})

require("oil").setup({
	default_file_explorer = true,
	columns = vim.g.have_nerd_font and { "icon" } or {},
	keymaps = {
		["\\"] = "actions.close",
	},
	view_options = {
		show_hidden = true,
		highlight_filename = function(entry, is_hidden)
			if is_hidden then
				return nil
			end
			local status_map = vim.b[0].oil_git_status
			if not status_map then
				return nil
			end
			local s = status_map[entry.name]
			if not s then
				return nil
			end
			if s == "M " or s == " M" or s == "MM" then
				return "DiffChange"
			elseif s == "A " then
				return "DiffAdd"
			elseif s == "D " or s == " D" then
				return "DiffDelete"
			elseif s == "??" then
				return "DiagnosticHint"
			elseif s == "R " then
				return "DiffText"
			end
			return nil
		end,
	},
})
