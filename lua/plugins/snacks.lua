return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      -- Global settings for all pickers
      hidden = true,
      ignored = false,
      exclude = {
        "node_modules",
        "dist",
        "build",
        "target",
        "vendor",
        ".git",
        "%.lock$",
      },
      include = {
        ".env*",
        ".htaccess",
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
            "dist",
            "build",
            "target",
            "vendor",
            ".git",
          },
          hidden = true,
          ignored = false,
          follow_file = true,
          tree = true,
          auto_close = false,
        },
        -- Files picker settings (for fuzzy search)
        files = {
          exclude = {
            "node_modules/",
            "dist/",
            "build/",
            "target/",
            "vendor/",
            ".git/",
            "%.lock$",
          },
          include = {
            ".env*",
            ".htaccess",
          },
          hidden = true,
          ignored = false,
        },
        -- Grep picker settings
        grep = {
          exclude = {
            "node_modules/",
            "dist/",
            "build/",
            "target/",
            "vendor/",
            ".git/",
            "%.lock$",
          },
          hidden = true,
          ignored = false,
        },
      },
    },
  },
}
