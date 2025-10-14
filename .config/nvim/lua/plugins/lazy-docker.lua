return {
  {
    "crnvl96/lazydocker.nvim",
    cmd = { "LazyDocker" },
    keys = {
      {
        "<leader>dd",
        function()
          require("lazydocker").toggle()
        end,
        desc = "Toggle LazyDocker",
        mode = { "n", "t" },
      },
    },
    config = function()
      require("lazydocker").setup({
        window = {
          settings = {
            width = 0.8,
            height = 0.8,
            border = "rounded",
            relative = "editor",
          },
        },
      })
    end,
  },
}
