return {
  "dmtrKovalenko/fold-imports.nvim",
  opts = {
    languages = {
      java = {
        enabled = true,
        parsers = { "java" },
        queries = {
          "(import_declaration) @import",
          "(package_declaration) @package",
        },
        filetypes = { "java" },
        patterns = { "*.java" },
      },
    },
  },
  event = "BufRead",
}
