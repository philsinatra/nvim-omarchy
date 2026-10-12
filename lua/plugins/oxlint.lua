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
    -- No bin_path: the plugin uses `bin_path or find_binary()`, so setting it would
    -- bypass the project-local resolution in find_binary below.
    run = "onType",
    enable = true,
    config_path = ".oxlintrc.json",
  },
  config = function(_, opts)
    local oxlint = require("nvim-oxlint")

    -- Resolve oxlint project-local first, global second.
    --
    -- A project's .oxlintrc.json is only valid for the oxlint version that project
    -- pins: oxlint hard-fails config parsing on a rule name it does not recognize,
    -- so a global binary that is older or newer than the project's pin silently
    -- disables ALL diagnostics. Preferring node_modules/.bin keeps each repo's
    -- linting reproducible; the global binary stays the fallback for scratch files
    -- and projects with no local install.
    --
    -- Resolution walks up from the buffer's own path rather than vim.fn.getcwd(),
    -- so it stays correct when editing a file outside the editor's working dir.
    oxlint.find_binary = function(bufnr)
      local buf_path = vim.api.nvim_buf_get_name(bufnr or 0)
      local start = (buf_path ~= "" and buf_path) or (vim.fn.getcwd() .. "/.")

      for dir in vim.fs.parents(start) do
        local local_bin = dir .. "/node_modules/.bin/oxlint"
        if vim.fn.executable(local_bin) == 1 then
          return { local_bin, "--lsp" }
        end
      end

      if vim.fn.executable("oxlint") == 1 then
        return { "oxlint", "--lsp" }
      end

      return nil
    end

    oxlint.setup(opts)
  end,
}
