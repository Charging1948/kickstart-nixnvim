require('config.format.autocmds')

require('lze').load {
  {
    "conform.nvim",
    for_cat = 'format',
    cmd = { "Format" },
    -- event = "",
    -- ft = "",
    keys = {
      { "<leader>cf", desc = "[C]ode [F]ormat" },
    },
    -- colorscheme = "",
    after = function(plugin)
      local conform = require("conform")

      conform.setup({
        formatters_by_ft = {
          -- NOTE: download some formatters in lspsAndRuntimeDeps
          -- and configure them here
          lua = { "stylua" },
          go = { "gofumpt", "golines", "goimports" },
          templ = { "templ" },
          python = { "ruff_format" },
          javascript = { "prettierd", "prettier", stop_after_first = true },
          typescript = { "prettierd", "prettier", stop_after_first = true },
        },
      })

      vim.keymap.set({ "n", "v" }, "<leader>cf", function()
        conform.format({
          lsp_fallback = true,
          async = false,
          timeout_ms = 1000,
        })
      end, { desc = "[C]ode [F]ormat" })
    end,
  },
}
