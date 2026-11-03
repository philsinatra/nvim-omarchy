return {
  "mg979/vim-visual-multi",
  branch = "master",
  init = function()
    -- vim-visual-multi overwrites buffer-local insert maps (<CR>, <BS>, <Up>, <Down>,
    -- <C-e>, <C-b>, <C-f>, ...) while active, then `iunmap <buffer>`s them on exit.
    -- That deletes blink.cmp's buffer-local <CR> accept mapping, and blink never
    -- re-applies it because its other buffer maps (<Tab>, <C-n>, ...) still exist.
    -- Result: after using multi-cursor in a buffer, Enter stops accepting completions
    -- (incl. Emmet) and falls through to mini.pairs' newline. Re-apply on VM exit.
    vim.api.nvim_create_autocmd("User", {
      pattern = "visual_multi_exit",
      group = vim.api.nvim_create_augroup("vm_restore_blink_keymaps", { clear = true }),
      callback = function()
        local ok, apply = pcall(require, "blink.cmp.keymap.apply")
        if not ok then
          return
        end
        local config = require("blink.cmp.config")
        if not config.enabled() then
          return
        end
        -- Remove the surviving blink maps so its "already applied" check doesn't skip us
        for _, m in ipairs(vim.api.nvim_buf_get_keymap(0, "i")) do
          if m.desc and vim.startswith(m.desc, apply.DESC_PREFIX) then
            pcall(vim.keymap.del, "i", m.lhs, { buffer = 0 })
          end
        end
        apply.keymap_to_current_buffer(require("blink.cmp.keymap").get_mappings(config.keymap, "default"))
      end,
    })
  end,
}
