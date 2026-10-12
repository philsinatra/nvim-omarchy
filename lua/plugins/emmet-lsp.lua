return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      -- emmet-ls may still be installed; keep mason-lspconfig from auto-enabling it
      emmet_ls = { enabled = false },
      emmet_language_server = {
        filetypes = {
          "css",
          "eruby",
          "html",
          "htmldjango",
          "javascriptreact",
          "less",
          "pug",
          "sass",
          "scss",
          "typescriptreact",
          "php",
          "svelte",
        },
      },
    },
  },
}
