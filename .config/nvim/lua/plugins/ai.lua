local sidekick_cli = "opencode2"

return {
  -- ===== Quickchat in-editor (opencode v1) =====
  {
    "nickjvandyke/opencode.nvim",
    version = "*",
    config = function()
      vim.g.opencode_opts = {
        server = {
          start = function()
            require("snacks.terminal").open("opencode --port", {
              win = { position = "right", enter = false },
            })
          end,
        },
      }
      vim.keymap.set({ "n", "x" }, "<leader>aq", function()
        require("opencode").ask("@this: ")
      end, { desc = "OpenCode Quick Ask" })
    end,
  },

  -- ===== Painel/TUI (opencode2) =====
  {
    "folke/sidekick.nvim",
    opts = {
      nes = {
        enabled = false,
      },
      copilot = {
        status = {
          level = vim.log.levels.OFF,
        },
      },
      cli = {
        win = {
          layout = "right",
        },
        mux = {
          backend = "tmux",
          enabled = true,
        },
        tools = {
          opencode2 = {
            -- ponytail: --standalone evita o background service,
            -- que falha ao spawnar o .exe (ENOEXEC) em tmux
            cmd = { "opencode2", "--standalone" },
            is_proc = "\\<opencode2\\>",
            native_scroll = true,
          },
        },
      },
    },
    keys = {
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

  -- ===== Garante que só os 2 acima ficam ativos =====
  { "zbirenbaum/copilot.lua", enabled = false },
  { "copilotlsp-nvim/copilot-lsp", enabled = false },
  { "olimorris/codecompanion.nvim", enabled = false },

  --[[
  -- ===== Alternativa (desativada): frontend nativo completo =====
  -- sudo-tee/opencode.nvim faz painel + quick chat num plugin só, dentro do
  -- Neovim (sem terminal). Ative APENAS se quiser abandonar sidekick +
  -- nickjvandyke, senão vira redundante. Prefixo <leader>a evita colidir com
  -- onioncrab (<leader>o), MAS conflita com o sidekick — desative os blocos
  -- acima antes de ativar este. Nota: só opencode v1, NÃO suporta opencode2.
  {
    "sudo-tee/opencode.nvim",
    config = function()
      require("opencode").setup({
        keymap_prefix = "<leader>a", -- remapeia <leader>o* -> <leader>a*
        -- default_mode = "build",
        -- ui = { position = "right" },
      })
    end,
    dependencies = {
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = { file_types = { "markdown", "opencode_output" } },
        ft = { "markdown", "opencode_output" },
      },
      "saghen/blink.cmp",
      "folke/snacks.nvim",
    },
  },
  -- Atalhos principais (após ativar):
  --   <leader>a/  quick chat (seleção/linha -> edita o trecho)
  --   <leader>ag  toggle painel
  --   <leader>ai  input atual   <leader>aI  nova sessão
  --   <leader>ao  output
  --   <leader>ap  provider/modelo
  --   <leader>ad  diff   <leader>ac fecha   <leader>ara revert último prompt
  --]]
}
