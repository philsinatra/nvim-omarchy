return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      cssls = {},
      html = {},
      svelte = {},
      ts_ls = {},
      lua_ls = {},
      -- Add others if needed; biome and emmet are already configured
    },
  },
}
