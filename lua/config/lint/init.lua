local M = {}

if nixCats("languages.latex") then
  M.tex = { 'chktex' }
end

require('lze').load {
  {
    "nvim-lint",
    for_cat = 'lint',
    -- cmd = { "" },
    event = "FileType",
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    after = function(plugin)
      require('lint').linters_by_ft = {
        -- NOTE: download some linters in lspsAndRuntimeDeps
        -- and configure them here
        astro = { 'oxlint' },
        svelte = { 'oxlint' },
        vue = { 'oxlint' },
        bash = { 'bash', 'shellcheck' },
        fish = { 'fish' },
        go = { 'golangcilint' },
        python = { 'ruff' },
        lua = { 'selene' },
        sql = { 'sqlfluff' },
        nix = { 'deadnix', 'statix' },
        html = { 'tidy' },
        tex = M.tex or {},
        -- markdown = {'vale',},
        editorconfig = { 'editorconfig-checker' },
        javascript = { 'oxlint' },
        typescript = { 'oxlint' },
        env = { 'dotenv_linter' },
        yaml = { 'yamllint' },
      }

      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        callback = function()
          require("lint").try_lint()
        end,
      })
    end,
  },
}
