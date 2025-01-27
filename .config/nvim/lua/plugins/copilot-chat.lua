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
        height = 0.85,
      },
      model = "claude-3.5-sonnet",
      show_help = false,
      -- auto_insert_mode = false,
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
        "<leader>cpo",
        mode = { "n", "v" },
        "<cmd>CopilotChatToggle<cr>",
        desc = "Toggle chat",
      },
      -- Reset chat
      {
        "<leader>cpr",
        mode = { "n", "v" },
        ":CopilotChatReset<cr>",
        desc = "Reset chat",
      },
      -- Quick chat with Copilot
      {
        "<leader>cpq",
        mode = { "n", "v" },
        function()
          local input = vim.fn.input("Quick Chat: ")
          if input ~= "" then
            require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
          end
        end,
        desc = "CopilotChat - Quick chat",
      },
    },
  },
}
