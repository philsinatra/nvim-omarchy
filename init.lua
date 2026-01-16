-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- Enable autoread
vim.opt.autoread = true

-- Trigger checktime to refresh buffers when files change on disk
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  pattern = "*",
  command = "if mode() != 'c' | checktime | endif",
})

-- Optional: Notify you when a file is reloaded
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  callback = function()
    vim.notify("File changed on disk. Buffer reloaded!", vim.log.levels.INFO)
  end,
})
