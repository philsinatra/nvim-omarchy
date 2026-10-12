return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    -- Extend ensure_installed to include svelte
    opts.ensure_installed = opts.ensure_installed or {}
    vim.list_extend(
      opts.ensure_installed,
      { "html", "css", "javascript", "typescript", "tsx", "json", "php", "phpdoc", "svelte", "markdown" }
    )
    -- Enable highlighting and indentation
    opts.highlight = { enable = true }
    opts.indent = { enable = true }
  end,
  build = ":TSUpdate",
}
