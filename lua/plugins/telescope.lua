return {
  "nvim-telescope/telescope.nvim",
  opts = function(_, opts)
    -- Set file ignore patterns for all pickers
    opts.defaults = opts.defaults or {}
    opts.defaults.file_ignore_patterns = {
      "^%.git/",
      "^node_modules/",
      "^dist/",
      "^build/",
      "^target/",
      "%.lock$",
    }

    opts.pickers = opts.pickers or {}

    -- Configure find_files picker
    opts.pickers.find_files = opts.pickers.find_files or {}
    if vim.fn.executable("fd") == 1 then
      opts.pickers.find_files.find_command = {
        "fd",
        "--type",
        "f",
        "--color",
        "never",
        "--hidden",
        "--follow",
        "-E",
        ".git",
        "-E",
        "node_modules",
        "-E",
        "dist",
        "-E",
        "build",
        "-E",
        "target",
      }
    end

    -- Configure git_files picker to show untracked files and respect ignore patterns
    opts.pickers.git_files = opts.pickers.git_files or {}
    opts.pickers.git_files.show_untracked = true
    opts.pickers.git_files.use_git_root = false

    return opts
  end,
}
