return {
  -- Cores
  { "kepano/flexoki-neovim", name = "flexoki" },
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  { "rebelot/kanagawa.nvim", name = "kanagawa" },
  { "nyoom-engineering/nyoom.nvim", name = "nyoom" },
  { "jacoborus/tender.vim", name = "tender" },
  { "loctvl842/monokai-pro.nvim", name = "monokai-pro" },
  { "Mofiqul/vscode.nvim", name = "vscode" },
  { "navarasu/onedark.nvim", name = "onedark" },
  { "nickkadutskyi/jb.nvim", name = "jetbrains" },
  { "Mofiqul/dracula.nvim", name = "dracula" },
  {
    "rose-pine/neovim",
    name = "rose-pine",
  },
  -- Explorador de arquivos
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      {
        "<leader>e",
        function()
          require("oil").toggle_float(LazyVim.root())
        end,
        desc = "Explorer Oil (Root Dir)",
      },
      {
        "<leader>E",
        function()
          require("oil").toggle_float(vim.fn.expand("%:p:h"))
        end,
        desc = "Explorer Oil (Buffer Dir)",
      },
    },
    lazy = false,
    opts = {
      skip_confirm_for_simple_edits = true,
      prompt_save_on_select_new_entry = true,
      keymaps = {
        ["q"] = "actions.close",
        ["<C-p>"] = false,
        ["<C-l>"] = false,
      },
      view_options = {
        show_hidden = true,
      },
      float = {
        padding = 4,
        max_width = 0.8,
        max_height = 0.8,
        border = "rounded",
      },
    },
  },
  -- Abas (tabs) | DESATIVANDO
  {
    "akinsho/bufferline.nvim",
    enabled = false,
  },
  -- Cores em tab,{},(),[]
  {
    "HiPhish/rainbow-delimiters.nvim",
    config = function()
      local rainbow_delimiters = require("rainbow-delimiters")

      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow_delimiters.strategy["global"],
          vim = rainbow_delimiters.strategy["local"],
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
        },
        priority = {
          [""] = 110,
          lua = 210,
        },
        highlight = {
          -- "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      }
    end,
  },
  -- Menu de comandos nvim
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        {
          "<leader>a",
          group = "AI",
        },
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
  },
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      opts.dashboard = opts.dashboard or {}
      opts.dashboard.preset = opts.dashboard.preset or {}
      opts.dashboard.preset.header = [[
             ,-'"""`-.
           ,'         `.
          /        `    \
 `.      (    /          )
   `-.   |             " |
      º. (               )
one     `.\\          \ /
          `:.     , \ ,\ _
            `:-.___,-`-.{\)
              `.        |/ \
must            `.        \ \
                  `-.     _\,)
                     `.  |,-||
imagine sisyphus happy `.|| ||
      ]]
    end,
  },
  -- voltar comand line pra versão nativa, sem interferências
  {
    "folke/noice.nvim",
    opts = {
      cmdline = {
        enabled = true,
        view = "cmdline",
      },
    },
  },
}
