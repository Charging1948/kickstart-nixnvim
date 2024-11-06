local M = {}

-- Helper function to extract PR number from various URL formats
local function extract_pr_number(url)
  -- Match common GitHub PR URL patterns
  local number = url:match("github.com/NixOS/nixpkgs/pull/(%d+)")
  if not number then
    number = url:match("github.com/NixOS/nixpkgs/issues/(%d+)")
  end
  return number
end

-- Get commits from a PR and check if they are in nixos-unstable
local function check_pr_commits(pr_number)
  -- First get the commits from the PR
  local cmd = string.format(
    "gh pr view %s --repo NixOS/nixpkgs --json commits --jq '.commits[].oid'",
    pr_number
  )
  local handle = io.popen(cmd)
  if not handle then return {} end

  local result = handle:read("*a")
  handle:close()

  local commits = {}
  for commit in result:gmatch("[^\r\n]+") do
    -- For each commit, check if it's in nixos-unstable using git
    local check_cmd = string.format(
      "git -C $(gh repo clone NixOS/nixpkgs --no-checkout --single-branch -b nixos-unstable 2>/dev/null || echo $(git rev-parse --git-dir)/../nixpkgs) merge-base --is-ancestor %s nixos-unstable",
      commit
    )
    local success = os.execute(check_cmd)

    table.insert(commits, {
      hash = commit,
      in_unstable = success
    })
  end
  return commits
end

-- Function to create a separator line
local function create_separator(width)
  return string.rep("─", width)
end

-- Main function to check PR status
function M.check_pr_under_cursor()
  -- Get URL under cursor
  local url = vim.fn.expand('<cfile>')
  local pr_number = extract_pr_number(url)

  if not pr_number then
    vim.notify("No nixpkgs PR URL found under cursor", vim.log.levels.ERROR)
    return
  end

  -- Create floating window for output
  local buf = vim.api.nvim_create_buf(false, true)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = 'minimal',
    border = 'rounded'
  })

  -- Set buffer options
  vim.api.nvim_set_option_value('modifiable', false, { buf = buf })
  vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = buf })

  -- Function to append lines to buffer
  local function append_line(line)
    vim.api.nvim_set_option_value('modifiable', true, { buf = buf })
    vim.api.nvim_buf_set_lines(buf, -1, -1, false, { line })
    vim.api.nvim_set_option_value('modifiable', false, { buf = buf })
  end

  append_line(string.format("Checking PR #%s in NixOS/nixpkgs...", pr_number))
  append_line("")

  -- Get and check commits
  local commits = check_pr_commits(pr_number)
  if #commits == 0 then
    append_line("No commits found in PR")
    return
  end

  append_line(string.format("Found %d commits:", #commits))
  append_line("")

  -- Track commits not in unstable
  local missing_commits = {}

  -- Show results
  for _, commit in ipairs(commits) do
    local symbol = commit.in_unstable and "✓" or "⨯"
    append_line(string.format("%s %s %s",
      symbol,
      commit.hash:sub(1, 7),
      commit.in_unstable and "in nixos-unstable" or "not in nixos-unstable"
    ))

    if not commit.in_unstable then
      table.insert(missing_commits, commit.hash:sub(1, 7))
    end
  end

  -- Add prominent summary message
  append_line("")
  append_line(create_separator(width - 2))
  append_line("")

  if #missing_commits == 0 then
    append_line("🎉 STATUS: All commits have been merged into nixos-unstable! 🎉")
    append_line("You can safely remove any temporary fixes related to this PR.")
  else
    append_line("⚠️  ATTENTION: Some commits are still missing from nixos-unstable! ⚠️")
    append_line(string.format("Missing commits: %s", table.concat(missing_commits, ", ")))
    append_line("Keep any temporary fixes related to this PR.")
  end

  append_line("")
  append_line(create_separator(width - 2))

  -- Add close keybinding
  vim.api.nvim_buf_set_keymap(buf, 'n', 'q', ':close<CR>', {
    noremap = true,
    silent = true
  })

  -- Also send a notification
  if #missing_commits == 0 then
    vim.notify(
      string.format("PR #%s: All commits are in nixos-unstable!", pr_number),
      vim.log.levels.INFO,
      { title = "NixPkgs PR Check" }
    )
  else
    vim.notify(
      string.format("PR #%s: %d commit(s) still missing from nixos-unstable", pr_number, #missing_commits),
      vim.log.levels.WARN,
      { title = "NixPkgs PR Check" }
    )
  end
end

-- Set up command and optional keybinding
function M.setup(opts)
  opts = opts or {}

  vim.api.nvim_create_user_command('NixPkgsPRCheck', M.check_pr_under_cursor, {})

  if opts.mapping then
    vim.keymap.set('n', opts.mapping, M.check_pr_under_cursor, {
      noremap = true,
      silent = true,
      desc = "Check nixpkgs PR status"
    })
  end
end

return M
