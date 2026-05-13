return {
  dir = "/home/heitor/onioncrab.nvim",
  name = "onioncrab.nvim",
  dependencies = {
    { "ThePrimeagen/harpoon", branch = "harpoon2" },
  },
  keys = {
    {
      "<leader>oa",
      function()
        require("onioncrab").add()
      end,
      desc = "Onioncrab: Add",
      mode = "n",
    },
    {
      "<leader>om",
      function()
        require("onioncrab").menu()
      end,
      desc = "Onioncrab: Menu",
      mode = "n",
    },
    {
      "<leader>oo",
      function()
        require("onioncrab").open()
      end,
      desc = "Onioncrab: Open",
      mode = "n",
    },
    {
      "<leader>oh",
      function()
        require("onioncrab").left()
      end,
      desc = "Onioncrab: Left",
      mode = "n",
    },
    {
      "<leader>ol",
      function()
        require("onioncrab").right()
      end,
      desc = "Onioncrab: Right",
      mode = "n",
    },
    {
      "<leader>ok",
      function()
        require("onioncrab").up()
      end,
      desc = "Onioncrab: Up",
      mode = "n",
    },
    {
      "<leader>oj",
      function()
        require("onioncrab").down()
      end,
      desc = "Onioncrab: Down",
      mode = "n",
    },
  },
  config = function()
    require("harpoon"):setup()
    require("onioncrab").setup()
  end,
}
