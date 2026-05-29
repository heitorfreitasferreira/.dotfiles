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

vim.api.nvim_create_user_command("CompileJava", function()
  local dir = vim.fn.expand("%:p:h")
  local pom = vim.fn.findfile("pom.xml", dir .. ";")
  if pom ~= "" then
    vim.fn.jobstart({ "mvn", "-f", pom, "compile", "-q" }, { detach = true })
    vim.notify("Compilando Java: " .. pom, vim.log.levels.INFO)
  else
    vim.notify("pom.xml nao encontrado", vim.log.levels.WARN)
  end
end, { desc = "Compila o projeto Maven atual via mvn compile -q" })
