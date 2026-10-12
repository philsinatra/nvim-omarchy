return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      intelephense = {
        settings = {
          intelephense = {
            files = {
              maxSize = 1000000,
              associations = { "*.php", "*.phtml" },
              exclude = {
                "**/vendor/**",
                "**/node_modules/**",
                "**/.git/**",
              },
            },
            format = {
              enable = true,
            },
            environment = {
              includePaths = { "vendor" },
            },
            -- Enable completion features
            completion = {
              insertUseDeclaration = true,
              fullyQualifyGlobalConstantsAndFunctions = false,
            },
          },
        },
        filetypes = { "php" }, -- Explicitly set filetypes
      },
    },
  },
}
