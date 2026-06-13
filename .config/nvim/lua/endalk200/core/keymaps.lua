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

-- tabs & indentation
vim.opt.tabstop = 2 -- 2 spaces for tabs (prettier default)
vim.opt.shiftwidth = 2 -- 2 spaces for indent width
vim.opt.expandtab = true -- expand tab to spaces
vim.opt.autoindent = true -- copy indent from current line when starting new one
vim.opt.smartindent = true

-- line numbers
vim.opt.relativenumber = true -- show relative line numbers
vim.opt.number = true -- shows absolute line number on cursor line (when relative number is on)

-- diagnostics
vim.keymap.set('n', 'gl', vim.diagnostic.open_float, { desc = 'Show full diagnostic message' })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic' })

-- Example mappings you can add anywhere after setup:
vim.keymap.set('n', '<leader>cC', '<cmd>CodeCompanionActions<cr>', { desc = 'CodeCompanion: Actions' })

-- If your version supports selecting adapters directly:
vim.keymap.set('n', '<leader>cp', '<cmd>CodeCompanionChat copilot<cr>', { desc = 'Chat (Copilot)' })
vim.keymap.set('n', '<leader>ca', '<cmd>CodeCompanionChat aigw<cr>', { desc = 'Chat (AIGW)' })
