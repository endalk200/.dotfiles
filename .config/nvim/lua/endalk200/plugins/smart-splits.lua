return {
  'smart-splits-nvim/smart-splits.nvim',
  tag = 'v3.0.0',
  dependencies = {
    'rawnly/smart-splits-backend-rex',
  },
  config = function()
    local splits = require 'smart-splits'

    splits.setup {
      mux = {
        backend = 'smart-splits-backend-rex',
      },
      move = {
        at_edge = 'stop',
      },
    }

    vim.keymap.set('n', '<C-h>', splits.move_cursor_left, { desc = 'Move focus left' })
    vim.keymap.set('n', '<C-j>', splits.move_cursor_down, { desc = 'Move focus down' })
    vim.keymap.set('n', '<C-k>', splits.move_cursor_up, { desc = 'Move focus up' })
    vim.keymap.set('n', '<C-l>', splits.move_cursor_right, { desc = 'Move focus right' })
  end,
}
