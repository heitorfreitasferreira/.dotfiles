return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "github/copilot.vim" }, -- or zbirenbaum/copilot.lua
      { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
    },
    build = "make tiktoken", -- Only on MacOS or Linux
    opts = {
      window = {
        layout = "float",
      },
      model = "claude-3.5-sonnet",
      show_help = false,
      auto_insert_mode = true,
    },
    setup = function()
      chat_autocomplete = false
    end,
    keys = {
      {
        "<leader>cpp",
        mode = { "n", "v" },
        function()
          local actions = require("CopilotChat.actions")
          require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
        end,
        desc = "Prompt actions",
      },
      -- Toggle da janela do chat
      {
        "<leader>cp",
        "<cmd>CopilotChatToggle<cr>",
        desc = "Toggle chat",
      },
      -- Explicar código selecionado
      {
        "<leader>cpe",
        ":CopilotChatExplain<cr>",
        mode = { "n", "v" },
        desc = "Explain code",
      },
      -- Revisar código selecionado
      {
        "<leader>cpr",
        ":CopilotChatReview<cr>",
        mode = { "n", "v" },
        desc = "Review code",
      },
      -- Refatorar código selecionado
      {
        "<leader>cpf",
        ":CopilotChatFix<cr>",
        mode = { "n", "v" },
        desc = "Fix/Refactor code",
      },
      -- Otimizar código selecionado
      {
        "<leader>cpo",
        ":CopilotChatOptimize<cr>",
        mode = { "n", "v" },
        desc = "Optimize code",
      },
      -- Gerar testes
      {
        "<leader>cpt",
        ":CopilotChatTests<cr>",
        mode = { "n", "v" },
        desc = "Generate tests",
      },
      -- Gerar documentação
      {
        "<leader>cpd",
        ":CopilotChatDocs<cr>",
        mode = { "n", "v" },
        desc = "Document code",
      },
      -- Reset chat
      {
        "<leader>cpr",
        ":CopilotChatReset<cr>",
        desc = "Reset chat",
      },
    },
  },
}
