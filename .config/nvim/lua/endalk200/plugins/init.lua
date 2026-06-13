return {
  'NMAC427/guess-indent.nvim',
  {
    'NoahTheDuke/vim-just',
    ft = { 'just' },
  },
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      delay = 0,
      icons = { mappings = vim.g.have_nerd_font },
      spec = {
        { '<leader>b', group = 'Buffers' },
        { '<leader>c', group = 'Code' },
        { '<leader>d', group = 'Debug' },
        { '<leader>e', group = 'Explorer' },
        { '<leader>f', group = 'Find/Format' },
        { '<leader>g', group = 'Git' },
        { '<leader>h', group = 'Git hunks', mode = { 'n', 'v' } },
        { '<leader>s', group = 'Splits' },
        { '<leader>t', group = 'Toggle' },
      },
    },
  },
  require 'endalk200.core.colortheme',
  require 'endalk200.plugins.alpha',
  require 'endalk200.plugins.autocomplete',
  require 'endalk200.plugins.autopairs',
  require 'endalk200.plugins.bufferline',
  require 'endalk200.plugins.cloak',
  require 'endalk200.plugins.debug',
  require 'endalk200.plugins.dressing',
  require 'endalk200.plugins.fold',
  require 'endalk200.plugins.formatting',
  require 'endalk200.plugins.gitsigns',
  require 'endalk200.plugins.indent_line',
  require 'endalk200.plugins.lazygit',
  require 'endalk200.plugins.lint',
  require 'endalk200.plugins.lsp',
  require 'endalk200.plugins.lualine',
  require 'endalk200.plugins.nvim-tree',
  require 'endalk200.plugins.telescope.main',
  require 'endalk200.plugins.treesitter',
  require 'endalk200.plugins.vim-tmux-navigator',
  require 'endalk200.plugins.ai',
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },
  {
    'echasnovski/mini.nvim',
    config = function()
      require('mini.ai').setup { n_lines = 500 }
      require('mini.surround').setup()
      require('mini.icons').setup()
    end,
  },
}
