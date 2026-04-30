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
    "Exafunction/codeium.nvim",
    enabled = true,
    cmd = "Codeium",
    event = "InsertEnter",
    build = ":Codeium Auth",
    opts = {
      enable_cmp_source = false,
      virtual_text = {
        enabled = false,
        key_bindings = {
          accept = false,
          clear = false,
          next = "<M-]>",
          prev = "<M-[>",
        },
      },
    },
  },
  {
    "saghen/blink.cmp",
    optional = true,
    dependencies = { "Exafunction/codeium.nvim", "fang2hou/blink-copilot" },
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      opts.sources.default = opts.sources.default or {}

      if not vim.tbl_contains(opts.sources.default, "codeium") then
        table.insert(opts.sources.default, "codeium")
      end

      if not vim.tbl_contains(opts.sources.default, "copilot") then
        table.insert(opts.sources.default, "copilot")
      end

      opts.sources.providers = opts.sources.providers or {}
      opts.sources.providers.codeium = vim.tbl_deep_extend("force", opts.sources.providers.codeium or {}, {
        name = "Codeium",
        module = "codeium.blink",
        async = true,
      })
      opts.sources.providers.copilot = vim.tbl_deep_extend("force", opts.sources.providers.copilot or {}, {
        name = "copilot",
        module = "blink-copilot",
        async = true,
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
          require("sidekick.cli").toggle()
        end,
        desc = "Sidekick Toggle",
        mode = { "n", "t", "i", "x" },
      },
      {
        "<leader>aa",
        function()
          require("sidekick.cli").toggle({ name = "opencode", focus = true })
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
          require("sidekick.cli").send({ msg = "{this}", name = "opencode", focus = true })
        end,
        mode = { "x", "n" },
        desc = "Send This",
      },
      {
        "<leader>af",
        function()
          require("sidekick.cli").send({ msg = "{file}", name = "opencode", focus = true })
        end,
        desc = "Send File",
      },
      {
        "<leader>av",
        function()
          require("sidekick.cli").send({ msg = "{selection}", name = "opencode", focus = true })
        end,
        mode = { "x" },
        desc = "Send Visual Selection",
      },
      {
        "<leader>ap",
        function()
          require("sidekick.cli").prompt({ name = "opencode", focus = true })
        end,
        mode = { "n", "x" },
        desc = "Sidekick Select Prompt",
      },
    },
  },
}
