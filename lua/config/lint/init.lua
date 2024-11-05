require('lze').load {
  {
    "nvim-lint",
    for_cat = 'lint',
    -- cmd = { "" },
    event = "FileType",
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    after = function (plugin)
      require('lint').linters_by_ft = {
        -- NOTE: download some linters in lspsAndRuntimeDeps
        -- and configure them here
        go = {'golangcilint'},
        python = {'ruff'},
        lua = {'selene'},
        sql = {'sqlfluff'},
        nix = {'deadnix', 'statix'},
        html = {'tidy'},
        -- markdown = {'vale',},
        editorconfig = { 'editorconfig_checker' },
        javascript = { 'deno' },
        typescript = { 'deno' },
        env = {'dotenv_linter'},
        yaml = {'yamllint'},
      }

      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function()
          require("lint").try_lint()
        end,
      })
    end,
  },
}
