require('config.format.autocmds')

vim.api.nvim_create_user_command("FormatDisable", function(args)
  if args.bang then
    -- FormatDisable! will disable formatting just for this buffer
    vim.b.disable_autoformat = true
  else
    vim.g.disable_autoformat = true
  end
end, {
  desc = "Disable autoformat-on-save",
  bang = true,
})
vim.api.nvim_create_user_command("FormatEnable", function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, {
  desc = "Re-enable autoformat-on-save",
})

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
        format_on_save = function(bufnr)
          -- Disable with a global or buffer-local variable
          if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
            return
          end
          return { timeout_ms = 500, lsp_format = "fallback" }
        end,
        formatters_by_ft = {
          -- NOTE: download some formatters in lspsAndRuntimeDeps
          -- and configure them here
          nix = { "nixfmt" },
          lua = { "stylua" },
          go = { "gofumpt", "golines", "goimports" },
          templ = { "templ" },
          just = { "just" },
          injected = { "injected" },
          sql = { "sqlfluff" },
          python = { "ruff_organize_imports", "ruff_fix", "ruff_format" },
          javascript = { "deno_fmt", "prettierd", "prettier", stop_after_first = true },
          typescript = { "deno_fmt", "prettierd", "prettier", stop_after_first = true },
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
