-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<leader>m", function()
  vim.diagnostic.setqflist()
  vim.cmd("copen")
end, { desc = "List diagnostics in quickfix" })

-- convert a. b. c. lists to dashed lists in markdown
vim.keymap.set(
  "x",
  "<leader>dl",
  [[:s/^\s*[a-z]\.\s*/- /<CR>]],
  { desc = "Convert lettered list to dash list (selection only)" }
)

vim.keymap.set("n", "<leader>co", function()
  vim.cmd("copen")
  vim.cmd("wincmd J")
  vim.cmd("resize 15")
end, { desc = "Open quickfix at bottom" })

vim.keymap.set("n", "<leader>bo", "<cmd>!xdg-open %<cr>", { desc = "Open in browser" })
