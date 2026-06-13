return {
  'stevearc/dressing.nvim',
  event = 'VeryLazy',
  opts = {
    input = {
      -- Default prompt string
      default_prompt = 'Input',
      -- Trim trailing `:` from prompt
      trim_prompt = true,
      -- Border style
      border = 'rounded',
      -- 'editor' and 'win' positions the float relative to your cursor
      relative = 'cursor',
      -- Prefer width as a portion of available space
      prefer_width = 40,
      -- Min and max width
      min_width = 20,
      max_width = { 140, 0.9 },
      -- Window transparency
      win_options = {
        winblend = 0,
      },
    },
    select = {
      -- Priority list of preferred backends
      backend = { 'telescope', 'builtin' },
      -- Options for telescope selector
      telescope = nil,
      -- Options for built-in selector
      builtin = {
        border = 'rounded',
        relative = 'cursor',
        win_options = {
          winblend = 0,
        },
      },
    },
  },
}
