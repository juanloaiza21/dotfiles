-- Asegúrate de requerir nvim-lint explícitamente
local lint = require "lint"

-- Si no hay linters configurados todavía, configura algunos por defecto
if not lint.linters_by_ft then
  lint.linters_by_ft = {
    lua = { "luacheck" },
    -- Añade más configuraciones según tus necesidades
  }
end

-- List of linters to ignore during install
local ignore_install = {}

-- Helper function to find if value is in table.
local function table_contains(table, value)
  for _, v in ipairs(table) do
    if v == value then
      return true
    end
  end
  return false
end

-- Build a list of linters to install minus the ignored list.
local all_linters = {}
for _, v in pairs(lint.linters_by_ft) do
  for _, linter in ipairs(v) do
    if not table_contains(ignore_install, linter) and not table_contains(all_linters, linter) then
      table.insert(all_linters, linter)
    end
  end
end

require("mason-nvim-lint").setup {
  ensure_installed = all_linters,
  automatic_installation = true, -- Cambiado a true para instalar automáticamente
}

-- Configura el linteo automático
vim.api.nvim_create_autocmd({ "BufWritePost", "BufEnter" }, {
  callback = function()
    lint.try_lint()
  end,
})
