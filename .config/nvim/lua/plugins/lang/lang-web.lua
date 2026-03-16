return {
  {
    "neovim/nvim-lspconfig",
    init = function()
      vim.filetype.add({
        extension = {
          gohtml = "gotmpl",
          gotmpl = "gotmpl",
          tmpl = function(path)
            if path:match("%.go%.tmpl$") then
              return "gotmpl"
            end

            local go_mod = vim.fs.find("go.mod", { path = vim.fs.dirname(path), upward = true })[1]
            if go_mod then
              return "gotmpl"
            end

            return "template"
          end,
        },
      })
    end,
    opts = function(_, opts)
      opts.servers = opts.servers or {}

      opts.servers.html = vim.tbl_deep_extend("force", opts.servers.html or {}, {
        filetypes = { "html", "gotmpl", "gohtml", "gohtmltmpl", "htmltmpl", "templ" },
      })

      opts.servers.cssls = vim.tbl_deep_extend("force", opts.servers.cssls or {}, {
        filetypes = { "css", "scss", "less", "gotmpl", "gohtml", "gohtmltmpl", "htmltmpl", "templ" },
      })

      opts.servers.ts_ls = vim.tbl_deep_extend("force", opts.servers.ts_ls or {}, {
        filetypes = {
          "javascript",
          "javascriptreact",
          "javascript.jsx",
          "typescript",
          "typescriptreact",
          "typescript.tsx",
        },
      })

      opts.servers.emmet_language_server = vim.tbl_deep_extend("force", opts.servers.emmet_language_server or {}, {
        filetypes = {
          "css",
          "eruby",
          "html",
          "javascriptreact",
          "less",
          "sass",
          "scss",
          "typescriptreact",
          "gotmpl",
          "gohtml",
          "gohtmltmpl",
          "htmltmpl",
          "templ",
        },
      })
    end,
  },

  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.html = { "prettier" }
      opts.formatters_by_ft.css = { "prettier" }
      opts.formatters_by_ft.scss = { "prettier" }
      opts.formatters_by_ft.less = { "prettier" }
      opts.formatters_by_ft.javascript = { "prettier" }
      opts.formatters_by_ft.javascriptreact = { "prettier" }
      opts.formatters_by_ft.typescript = { "prettier" }
      opts.formatters_by_ft.typescriptreact = { "prettier" }
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, { "css", "html", "javascript", "tsx", "typescript", "gotmpl" })
    end,
  },

  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "html-lsp",
        "css-lsp",
        "typescript-language-server",
        "emmet-language-server",
        "prettier",
      })
    end,
  },
}
