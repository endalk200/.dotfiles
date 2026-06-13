-- window management
vim.keymap.set('n', '<leader>sv', '<C-w>v', { desc = 'Split windows vertically' }) -- split window vertically
vim.keymap.set('n', '<leader>sh', '<C-w>s', { desc = 'Split windows horizontally' }) -- split window horizontally
vim.keymap.set('n', '<leader>se', '<C-w>=') -- make split windows equal width & height
vim.keymap.set('n', '<leader>sx', ':close<CR>', { desc = 'Close the current split window' }) -- close current split window

vim.keymap.set('n', 'L', '<Cmd>BufferLineCycleNext<CR>', { desc = 'Cycle next buffer' })
vim.keymap.set('n', 'H', '<Cmd>BufferLineCyclePrev<CR>', { desc = 'Cycle previous buffer' })

vim.keymap.set('n', '<leader>bo', '<Cmd>BufferLineCloseOthers<CR>', { desc = 'Delete other buffers' })
vim.keymap.set('n', '<leader>bp', '<Cmd>BufferLineTogglePin<CR>', { desc = 'Toggle buffer pin' })
vim.keymap.set('n', '<leader>bd', '<Cmd>bdelete<CR>', { desc = 'Delete current buffer' })

vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlights' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set('n', 'K', function()
  if #vim.lsp.get_clients { bufnr = 0 } > 0 then
    vim.lsp.buf.hover {
      border = 'rounded',
      max_height = 25,
      max_width = 100,
    }
    return
  end

  vim.cmd.normal { 'K', bang = true }
end, { desc = 'Hover documentation' })

-- diagnostics
vim.keymap.set('n', 'gl', function()
  vim.diagnostic.open_float {
    border = 'rounded',
    focusable = true,
    source = 'if_many',
  }
end, { desc = 'Show full diagnostic message' })
vim.keymap.set('n', '[d', function()
  vim.diagnostic.jump { count = -1, float = true }
end, { desc = 'Go to previous diagnostic' })
vim.keymap.set('n', ']d', function()
  vim.diagnostic.jump { count = 1, float = true }
end, { desc = 'Go to next diagnostic' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic quickfix list' })

-- Example mappings you can add anywhere after setup:
vim.keymap.set('n', '<leader>cC', '<cmd>CodeCompanionActions<cr>', { desc = 'CodeCompanion: Actions' })

-- If your version supports selecting adapters directly:
vim.keymap.set('n', '<leader>cp', '<cmd>CodeCompanionChat copilot<cr>', { desc = 'Chat (Copilot)' })
vim.keymap.set('n', '<leader>ca', '<cmd>CodeCompanionChat aigw<cr>', { desc = 'Chat (AIGW)' })
