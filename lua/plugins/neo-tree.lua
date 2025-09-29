return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    window = {
      position = "right",
    },
    filesystem = {
      filtered_items = {
        visible = true, -- Set to true to show hidden files by default (optional)
        hide_dotfiles = false, -- Set to true to hide dotfiles (e.g., .git)
        hide_gitignored = true, -- Respect .gitignore (recommended)
        hide_by_name = { "node_modules", "dist", "build", "vendor", ".svelte-kit" }, -- Folders to hide
        never_show = { ".git", "node_modules", "vendor", ".svelte-kit" }, -- Always hide these, even if visible = true
      },
    },
  },
}
