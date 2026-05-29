local sidekick_cli = "cursor"

return {
  {
    "zbirenbaum/copilot.lua",
    enabled = true,
    dependencies = {
      {
        "copilotlsp-nvim/copilot-lsp",
        init = function()
          vim.g.copilot_nes_debounce = 500
        end,
      },
    },
    cmd = "Copilot",
    config = function()
      require("copilot").setup({
        suggestion = { enabled = false },
        panel = { enabled = false },
        nes = {
          enabled = true,
          auto_trigger = false,
        },
      })
    end,
  },
  {
    "folke/sidekick.nvim",
    opts = {
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
    },

    keys = {
      {
        "<tab>",
        function()
          -- if there is a next edit, jump to it, otherwise apply it if any
          if not require("sidekick").nes_jump_or_apply() then
            return "<Tab>" -- fallback to normal tab
          end
        end,
        expr = true,
        desc = "Goto/Apply Next Edit Suggestion",
      },
      {
        "<c-.>",
        function()
          require("sidekick.cli").toggle({ name = sidekick_cli, focus = true })
        end,
        desc = "Sidekick Toggle",
        mode = { "n", "t", "i", "x" },
      },
      {
        "<leader>aa",
        function()
          require("sidekick.cli").toggle({ name = sidekick_cli, focus = true })
        end,
        desc = "Sidekick Toggle CLI",
      },
      {
        "<leader>as",
        function()
          require("sidekick.cli").select({ filter = { installed = true } })
        end,
        desc = "Select CLI",
      },
      {
        "<leader>at",
        function()
          require("sidekick.cli").send({ msg = "{this}", name = sidekick_cli, focus = true })
        end,
        mode = { "x", "n" },
        desc = "Send This",
      },
      {
        "<leader>af",
        function()
          require("sidekick.cli").send({ msg = "{file}", name = sidekick_cli, focus = true })
        end,
        desc = "Send File",
      },
      {
        "<leader>av",
        function()
          require("sidekick.cli").send({ msg = "{selection}", name = sidekick_cli, focus = true })
        end,
        mode = { "x" },
        desc = "Send Visual Selection",
      },
      {
        "<leader>ap",
        function()
          require("sidekick.cli").prompt({ name = sidekick_cli, focus = true })
        end,
        mode = { "n", "x" },
        desc = "Sidekick Select Prompt",
      },
    },
  },
}
