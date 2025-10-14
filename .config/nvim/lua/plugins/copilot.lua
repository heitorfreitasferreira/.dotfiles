return {
  {
    "zbirenbaum/copilot.lua",
    enabled = false,
    dependencies = {
      {
        "copilotlsp-nvim/copilot-lsp",
        init = function()
          vim.g.copilot_nes_debounce = 500
        end,
      },
    },
    cmd = "Copilot",
  },
}
