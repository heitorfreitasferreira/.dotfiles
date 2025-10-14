return {
  "kepano/flexoki-neovim",
  name = "flexoki",
  lazy = false, -- make sure we load this during startup
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    vim.cmd("colorscheme flexoki-dark")
  end,
}
-- return {
--   "loctvl842/monokai-pro.nvim",
--   config = function()
--     require("monokai-pro").setup()
--   end,
-- }
-- return {
--   "folke/tokyonight.nvim",
--   lazy = true,
--   opts = { style = "night" },
-- }
-- return {
--   "projekt0n/github-nvim-theme",
--   name = "github-theme",
--   lazy = false, -- make sure we load this during startup if it is your main colorscheme
--   priority = 1000, -- make sure to load this before all the other start plugins
--   config = function()
--     require("github-theme").setup({})
--
--     vim.cmd("colorscheme github_dark_dimmed")
--   end,
-- }
