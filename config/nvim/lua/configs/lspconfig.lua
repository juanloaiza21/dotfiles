-- NvChad's lspconfig defaults() (called in the plugin spec before this file) already
-- registers the global "*" config (capabilities + on_init) and the LspAttach -> on_attach
-- autocmd using the modern vim.lsp.config API. Here we only add per-server overrides
-- and enable the servers. (mason installs them; see configs/mason-lspconfig.lua.)

-- Servers that use only the bundled nvim-lspconfig defaults + the global "*" config.
local servers = { "lua_ls", "pyright" }

-- lua_ls: extend the defaults with custom settings.
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      diagnostics = {
        enable = false, -- Disable all diagnostics from lua_ls
        -- globals = { "vim" },
      },
      workspace = {
        library = {
          vim.fn.expand "$VIMRUNTIME/lua",
          vim.fn.expand "$VIMRUNTIME/lua/vim/lsp",
          vim.fn.stdpath "data" .. "/lazy/ui/nvchad_types",
          vim.fn.stdpath "data" .. "/lazy/lazy.nvim/lua/lazy",
          "${3rd}/love2d/library",
        },
        maxPreload = 100000,
        preloadFileSize = 10000,
      },
    },
  },
})

vim.lsp.enable(servers)
