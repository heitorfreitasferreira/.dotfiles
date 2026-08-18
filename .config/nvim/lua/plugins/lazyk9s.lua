return {
  {
    "nikth0/lazyk9s.nvim",
    cmd = { "LazyK9s" },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      {
        "<leader>kk",
        ":LazyK9s<CR>",
        desc = "Open k9s",
        mode = { "n", "t" },
      },
    },
  },
}
