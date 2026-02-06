return {
  "soulsam480/nvim-oxlint",
  opts = {
    filetypes = {
      "javascript",
      "javascriptreact",
      "javascript.jsx",
      "typescript",
      "typescriptreact",
      "typescript.tsx",
    },
    bin_path = { "oxlint", "--lsp" }, -- Use oxlint with LSP flag
    run = "onType",
    enable = true,
    config_path = ".oxlintrc.json",
  },
  config = function(_, opts)
    -- Override the binary detection to use the actual oxlint binary
    local oxlint = require("nvim-oxlint")
    oxlint.find_binary = function(bufnr)
      -- Check for global oxlint first
      if vim.fn.executable("oxlint") == 1 then
        return { "oxlint", "--lsp" }
      end
      -- Check local node_modules
      local project_root = vim.fn.getcwd()
      local local_bin = project_root .. "/node_modules/.bin/oxlint"
      if vim.fn.executable(local_bin) == 1 then
        return { local_bin, "--lsp" }
      end
      return nil
    end
    oxlint.setup(opts)
  end,
}