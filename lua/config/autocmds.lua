-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Per-theme highlight tweaks for Omarchy themes (theme.lua is a symlink that gets replaced on theme switch)
local theme_overrides = {
  ["rose-pine-dark"] = {
    -- Rose Pine "pine" is too dark for strings; lighten it everywhere it's used as fg
    recolor = { [0x31748f] = 0x56a3c0 },
  },
}

local function apply_theme_overrides()
  local f = io.open(vim.fn.expand("~/.local/state/omarchy/current/theme.name"))
  if not f then
    return
  end
  local name = vim.trim(f:read("*a"))
  f:close()

  local o = theme_overrides[name]
  if not o or not o.recolor then
    return
  end
  for group, hl in pairs(vim.api.nvim_get_hl(0, {})) do
    local new_fg = hl.fg and o.recolor[hl.fg]
    if new_fg and not hl.link then
      hl.fg = new_fg
      vim.api.nvim_set_hl(0, group, hl)
    end
  end
end

vim.api.nvim_create_autocmd("ColorScheme", {
  group = vim.api.nvim_create_augroup("omarchy_theme_overrides", { clear = true }),
  callback = function()
    vim.schedule(apply_theme_overrides)
  end,
})
apply_theme_overrides()
