return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
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
