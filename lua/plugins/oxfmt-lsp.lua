-- Configures oxfmt --lsp using Neovim 0.11+ native LSP API.
-- No Mason entry needed; install oxfmt via npm in each project.
return {
  {
    "neovim/nvim-lspconfig",
    optional = true,
    init = function()
      vim.lsp.config("oxfmt", {
        cmd = { "oxfmt", "--lsp" },
        filetypes = {
          "javascript",
          "javascriptreact",
          "typescript",
          "typescriptreact",
          "css",
          "html",
          "json",
          "markdown",
        },
        root_markers = { ".oxfmtrc.json", "package.json", ".git" },
        on_new_config = function(config, root_dir)
          local local_bin = root_dir .. "/node_modules/.bin/oxfmt"
          if vim.fn.executable(local_bin) == 1 then
            config.cmd = { local_bin, "--lsp" }
          end
        end,
      })
      vim.lsp.enable("oxfmt")
    end,
  },
}
