-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function()
    pcall(vim.lsp.enable, "copilot")
  end,
  once = true,
})

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.java",
  group = vim.api.nvim_create_augroup("JavaCompileOnSave", { clear = true }),
  callback = function()
    local dir = vim.fn.expand("%:p:h")
    local pom = vim.fn.findfile("pom.xml", dir .. ";")
    if pom ~= "" then
      vim.fn.jobstart({ "mvn", "-f", pom, "compile", "-q" }, { detach = true })
    end
  end,
})
