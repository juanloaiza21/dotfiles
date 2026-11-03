-- Ensure these LSP servers are installed via mason. These are lspconfig server names.
-- Server setup + enabling lives in configs/lspconfig.lua (modern vim.lsp.config API),
-- so mason-lspconfig only handles installation here (automatic_enable = false).
require("mason-lspconfig").setup {
  ensure_installed = { "lua_ls", "pyright" },
  automatic_enable = false,
}
