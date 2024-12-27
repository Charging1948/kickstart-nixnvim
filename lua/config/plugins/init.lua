local colorschemeName = nixCats("colorscheme")
if not require("nixCatsUtils").isNixCats then
  colorschemeName = "catppuccin"
end
-- Could I lazy load on colorscheme with lze?
-- sure. But I was going to call vim.cmd.colorscheme() during startup anyway
-- this is just an example, feel free to do a better job!
vim.cmd.colorscheme(colorschemeName)

-- NOTE: you can check if you included the category with the thing wherever you want.
if nixCats("general.extra") then
  -- I didnt want to bother with lazy loading this.
  -- I could put it in opt and put it in a spec anyway
  -- and then not set any handlers and it would load at startup,
  -- but why... I guess I could make it load
  -- after the other lze definitions in the next call using priority value?
  -- didnt seem necessary.
  vim.g.loaded_netrwPlugin = 1
  require("oil").setup({
    default_file_explorer = true,
    columns = {
      "icon",
      -- "permissions",
      "size",
      -- "mtime",
    },
    keymaps = {
      ["g?"] = "actions.show_help",
      ["<CR>"] = "actions.select",
      ["<C-s>"] = "actions.select_vsplit",
      ["<C-h>"] = "actions.select_split",
      ["<C-t>"] = "actions.select_tab",
      ["<C-p>"] = "actions.preview",
      ["<C-c>"] = "actions.close",
      ["<C-l>"] = "actions.refresh",
      ["-"] = "actions.parent",
      ["_"] = "actions.open_cwd",
      ["`"] = "actions.cd",
      ["~"] = "actions.tcd",
      ["gs"] = "actions.change_sort",
      ["gx"] = "actions.open_external",
      ["g."] = "actions.toggle_hidden",
      ["g\\"] = "actions.toggle_trash",
    },
  })
  vim.keymap.set("n", "-", "<cmd>Oil<CR>", { noremap = true, desc = "Open Parent Directory" })
  vim.keymap.set("n", "<leader>-", "<cmd>Oil .<CR>", { noremap = true, desc = "Open nvim root directory" })
end

if nixCats("general.mini") then
  local icons = require("mini.icons")
  icons.setup()
  icons.mock_nvim_web_devicons()
  icons.tweak_lsp_kind()

  require("mini.indentscope").setup()
  require("mini.ai").setup()
  require("mini.align").setup()
end

if nixCats("neorg") then
  require("neorg").setup({
    load = {
      ["core.defaults"] = {},
      -- Also load telescope integration
      -- TODO: Setup keymaps and stuff https://github.com/nvim-neorg/neorg-telescope
      ["core.integrations.telescope"] = {},
    },
  })
end

require("lze").load({
  { import = "config.plugins.telescope" },
  { import = "config.plugins.treesitter" },
  { import = "config.plugins.completion" },
  {
    "lazydev.nvim",
    for_cat = "neonixdev",
    cmd = { "LazyDev" },
    ft = "lua",
    after = function(plugin)
      require("lazydev").setup({
        library = {
          { words = { "nixCats" }, path = (require("nixCats").nixCatsPath or "") .. "/lua" },
        },
      })
    end,
  },
  {
    "markdown-preview.nvim",
    -- NOTE: for_cat is a custom handler that just sets enabled value for us,
    -- based on result of nixCats('cat.name') and allows us to set a different default if we wish
    -- it is defined in luaUtils template in lua/nixCatsUtils/lzUtils.lua
    -- you could replace this with enabled = nixCats('cat.name') == true
    -- if you didnt care to set a different default for when not using nix than the default you already set
    for_cat = "general.markdown",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    ft = "markdown",
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreview <CR>", mode = { "n" }, noremap = true, desc = "markdown preview" },
      {
        "<leader>ms",
        "<cmd>MarkdownPreviewStop <CR>",
        mode = { "n" },
        noremap = true,
        desc = "markdown preview stop",
      },
      {
        "<leader>mt",
        "<cmd>MarkdownPreviewToggle <CR>",
        mode = { "n" },
        noremap = true,
        desc = "markdown preview toggle",
      },
    },
    before = function(plugin)
      vim.g.mkdp_auto_close = 0
    end,
  },
  {
    "undotree",
    for_cat = "general.extra",
    cmd = { "UndotreeToggle", "UndotreeHide", "UndotreeShow", "UndotreeFocus", "UndotreePersistUndo" },
    keys = { { "<leader>U", "<cmd>UndotreeToggle<CR>", mode = { "n" }, desc = "Undo Tree" } },
    before = function(_)
      vim.g.undotree_WindowLayout = 1
      vim.g.undotree_SplitWidth = 40
    end,
  },
  {
    "comment.nvim",
    for_cat = "general.extra",
    event = "DeferredUIEnter",
    after = function(plugin)
      require("Comment").setup()
    end,
  },
  {
    "nvim-autopairs",
    for_cat = "general.extra",
    event = "InsertEnter",
    after = function(plugin)
      require("nvim-autopairs").setup()

      -- If you want insert `(` after select function or method item
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp = require("cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },
  -- {
  --   "indent-blankline.nvim",
  --   for_cat = "general.extra",
  --   event = "DeferredUIEnter",
  --   after = function(plugin)
  --     require("ibl").setup()
  --   end,
  -- },
  {
    "nvim-surround",
    for_cat = "general.always",
    event = "DeferredUIEnter",
    -- keys = "",
    after = function(plugin)
      require("nvim-surround").setup()
    end,
  },
  {
    "vim-sleuth",
    for_cat = "general.always",
    event = "DeferredUIEnter",
  },
  {
    "vim-startuptime",
    for_cat = "general.extra",
    cmd = { "StartupTime" },
    before = function(plugin)
      vim.g.startuptime_event_width = 0
      vim.g.startuptime_tries = 10
      vim.g.startuptime_exe_path = require("nixCatsUtils").packageBinPath
    end,
  },
  {
    "fidget.nvim",
    for_cat = "general.extra",
    event = "DeferredUIEnter",
    -- keys = "",
    after = function(plugin)
      require("fidget").setup({})
    end,
  },
  {
    "grug-far.nvim",
    for_cat = "general.extra",
    -- event = "DeferredUIEnter",
    cmd = { "GrugFar" },
    keys = {
      {
        "<leader>sr",
        function()
          local grug = require("grug-far")
          local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
          grug.open({
            transient = true,
            prefills = {
              filesFilter = ext and ext ~= "" and "*." .. ext or nil,
            },
          })
        end,
        mode = { "n", "v" },
        desc = "[S]earch and [R]eplace",
      },
    },

    after = function(plugin)
      require("grug-far").setup({
        headerMaxWidth = 80,
      })
    end,
  },
  {
    "cord.nvim",
    for_cat = "general.extra",
    event = "DeferredUIEnter",
    keys = {
      {
        "<leader>uP",
        "<cmd>CordTogglePresence<cr>",
        mode = { "n" },
        desc = "Toggle [P]resence for Discord",
      },
    },

    after = function(plugin)
      require("cord").setup()
    end,
  },
  {
    "codesnap.nvim",
    for_cat = "general.extra",
    keys = {
      {
        "<leader>uc",
        "<cmd>CodeSnap<cr>",
        mode = "x",
        desc = "Save selected code snapshot into clipboard",
      },
      {
        "<leader>us",
        "<cmd>CodeSnapSave<cr>",
        mode = "x",
        desc = "Save selected code snapshot in ~/Pictures",
      },
      {
        "<leader>uC",
        "<cmd>CodeSnapHighlight<cr>",
        mode = "x",
        desc = "Save selected code snapshot into clipboard",
      },
      {
        "<leader>uS",
        "<cmd>CodeSnapSaveHighlight<cr>",
        mode = "x",
        desc = "Save selected code snapshot in ~/Pictures",
      },
    },
  },
  {
    "todo-comments.nvim",
    event = "DeferredUIEnter",
    for_cat = "general.extra",
    after = function(plugin)
      require("todo-comments").setup()
    end,
  },
  {
    "trouble.nvim",
    cmd = "Trouble",
    after = function(plugin)
      require("trouble").setup()
    end,
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
  },
  -- {
  --   "hlargs",
  --   for_cat = 'general.extra',
  --   event = "DeferredUIEnter",
  --   -- keys = "",
  --   dep_of = { "nvim-lspconfig" },
  --   after = function(plugin)
  --     require('hlargs').setup {
  --       color = '#32a88f',
  --     }
  --     vim.cmd([[hi clear @lsp.type.parameter]])
  --     vim.cmd([[hi link @lsp.type.parameter Hlargs]])
  --   end,
  -- },
  {
    "lualine.nvim",
    for_cat = "general.always",
    -- cmd = { "" },
    event = "DeferredUIEnter",
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    after = function(plugin)
      require("lualine").setup({
        options = {
          icons_enabled = true,
          theme = colorschemeName,
          component_separators = "|",
          section_separators = "",
        },
        sections = {
          lualine_c = {
            {
              "filename",
              path = 1,
              status = true,
            },
          },
        },
        inactive_sections = {
          lualine_b = {
            {
              "filename",
              path = 3,
              status = true,
            },
          },
          lualine_x = { "filetype" },
        },
        tabline = {
          lualine_a = { "buffers" },
          -- if you use lualine-lsp-progress, I have mine here instead of fidget
          -- lualine_b = { 'lsp_progress', },
          lualine_z = { "tabs" },
        },
      })
    end,
  },
  {
    "gitsigns.nvim",
    for_cat = "general.always",
    event = "DeferredUIEnter",
    -- cmd = { "" },
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    after = function(plugin)
      require("gitsigns").setup({
        -- See `:help gitsigns.txt`
        signs = {
          add = { text = "+" },
          change = { text = "~" },
          delete = { text = "_" },
          topdelete = { text = "‾" },
          changedelete = { text = "~" },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map({ "n", "v" }, "]c", function()
            if vim.wo.diff then
              return "]c"
            end
            vim.schedule(function()
              gs.next_hunk()
            end)
            return "<Ignore>"
          end, { expr = true, desc = "Jump to next hunk" })

          map({ "n", "v" }, "[c", function()
            if vim.wo.diff then
              return "[c"
            end
            vim.schedule(function()
              gs.prev_hunk()
            end)
            return "<Ignore>"
          end, { expr = true, desc = "Jump to previous hunk" })

          -- Actions
          -- visual mode
          map("v", "<leader>hs", function()
            gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, { desc = "stage git hunk" })
          map("v", "<leader>hr", function()
            gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
          end, { desc = "reset git hunk" })
          -- normal mode
          map("n", "<leader>gs", gs.stage_hunk, { desc = "git stage hunk" })
          map("n", "<leader>gr", gs.reset_hunk, { desc = "git reset hunk" })
          map("n", "<leader>gS", gs.stage_buffer, { desc = "git Stage buffer" })
          map("n", "<leader>gu", gs.undo_stage_hunk, { desc = "undo stage hunk" })
          map("n", "<leader>gR", gs.reset_buffer, { desc = "git Reset buffer" })
          map("n", "<leader>gp", gs.preview_hunk, { desc = "preview git hunk" })
          map("n", "<leader>gb", function()
            gs.blame_line({ full = false })
          end, { desc = "git blame line" })
          map("n", "<leader>gd", gs.diffthis, { desc = "git diff against index" })
          map("n", "<leader>gD", function()
            gs.diffthis("~")
          end, { desc = "git diff against last commit" })

          -- Toggles
          map("n", "<leader>gtb", gs.toggle_current_line_blame, { desc = "toggle git blame line" })
          map("n", "<leader>gtd", gs.toggle_deleted, { desc = "toggle git show deleted" })

          -- Text object
          map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", { desc = "select git hunk" })
        end,
      })
      vim.cmd([[hi GitSignsAdd guifg=#04de21]])
      vim.cmd([[hi GitSignsChange guifg=#83fce6]])
      vim.cmd([[hi GitSignsDelete guifg=#fa2525]])
    end,
  },
  {
    "which-key.nvim",
    for_cat = "general.extra",
    -- cmd = { "" },
    event = "DeferredUIEnter",
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    after = function(plugin)
      require("which-key").setup({})
      require("which-key").add({
        { "<leader><leader>", group = "buffer commands" },
        { "<leader><leader>_", hidden = true },
        { "<leader>c", group = "[c]ode" },
        { "<leader>c_", hidden = true },
        { "<leader>d", group = "[d]ocument" },
        { "<leader>d_", hidden = true },
        { "<leader>g", group = "[g]it" },
        { "<leader>g_", hidden = true },
        { "<leader>m", group = "[m]arkdown" },
        { "<leader>m_", hidden = true },
        { "<leader>r", group = "[r]ename" },
        { "<leader>r_", hidden = true },
        { "<leader>s", group = "[s]earch" },
        { "<leader>s_", hidden = true },
        { "<leader>u", group = "[u]tilities" },
        { "<leader>u_", hidden = true },
        { "<leader>x", group = "trouble" },
        { "<leader>x_", hidden = true },
        { "<leader>t", group = "[t]oggles" },
        { "<leader>t_", hidden = true },
        { "<leader>w", group = "[w]orkspace" },
        { "<leader>w_", hidden = true },
      })
    end,
  },
})
