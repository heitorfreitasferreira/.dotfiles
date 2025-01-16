return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  opts = {
    menu = {
      width = vim.api.nvim_win_get_width(0) - 4,
    },
    settings = {
      save_on_toggle = true,
    },
  },
  keys = function()
    local keys = {
      -- adiciona o arquivo ao harpoon
      {
        "<leader>ha",
        function()
          require("harpoon"):list():add()
        end,
        desc = "Harpoon File",
      },
      -- abre o menu do harpoon
      {
        "<leader>hh",
        function()
          local harpoon = require("harpoon")
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        desc = "Harpoon Quick Menu",
      },
      {
        "<leader>hda",
        function()
          require("harpoon"):list():clear()
        end,
        desc = "Harpoon clear all",
      },
    }

    for i = 1, 5 do
      -- abre o i-esimo buffer do harpoon
      table.insert(keys, {
        "<leader>" .. i,
        function()
          require("harpoon"):list():select(i)
        end,
        desc = "Harpoon to File " .. i,
      })
      -- remove o i-esimo buffer do harpoon
      table.insert(keys, {
        "<leader>hd" .. i,
        function()
          require("harpoon"):list():remove_at(i)
        end,
        desc = "Harpoon remove index " .. i,
      })
    end
    return keys
  end,
}
