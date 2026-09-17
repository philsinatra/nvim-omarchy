return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      -- Global settings for all pickers.
      --
      -- ignored = true means .gitignore no longer decides what the pickers show;
      -- `exclude` below is the single source of truth for what stays hidden.
      -- This is what keeps git-ignored-but-wanted paths (.env, dist) reachable
      -- while node_modules stays gone, since `exclude` is applied independently
      -- of gitignore (fd -E / rg -g '!...').
      hidden = true,
      ignored = true,
      exclude = {
        "node_modules",
        "target",
        "vendor",
        ".git",
        "*.lock",
      },
      sources = {
        -- Explorer-specific settings
        explorer = {
          layout = {
            layout = { position = "right" },
            auto_hide = { "input" },
          },
          exclude = {
            "node_modules",
            "target",
            "vendor",
            ".git",
          },
          hidden = true,
          ignored = true,
          follow_file = true,
          tree = true,
          auto_close = false,
        },
        -- Files picker settings (for fuzzy search)
        files = {
          exclude = {
            "node_modules/",
            "target/",
            "vendor/",
            ".git/",
            "*.lock",
          },
          hidden = true,
          ignored = true,
        },
        -- Grep picker settings
        grep = {
          exclude = {
            "node_modules/",
            "target/",
            "vendor/",
            ".git/",
            "*.lock",
          },
          hidden = true,
          ignored = true,
        },
      },
    },
  },
}
