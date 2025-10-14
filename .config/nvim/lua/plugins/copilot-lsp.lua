return {
  {
    "neovim/nvim-lspconfig",
    event = "VeryLazy",
    config = function()
      -- Habilita o servidor oficial do Copilot via API nativa do Neovim 0.11+
      -- Requer que o "copilot-language-server" esteja instalado no sistema
      -- e que o lspconfig tenha a definição "copilot" disponível.
      pcall(vim.lsp.enable, "copilot")
    end,
  },
}


