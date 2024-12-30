return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    spec = {
      {
        "<leader>h",
        group = "Harpoon",
      },
      {
        "<leader>cp",
        group = "Copilot Chat",
      },
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        local wk = require("which-key")
        wk.show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
}
