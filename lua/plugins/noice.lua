-- Don't pop up LSP signature help while typing. Show it on demand instead:
-- <C-k> in insert mode, gK in normal mode (LazyVim's LSP keymaps).
return {
	"folke/noice.nvim",
	opts = {
		lsp = {
			signature = {
				auto_open = { enabled = false },
			},
		},
	},
}
