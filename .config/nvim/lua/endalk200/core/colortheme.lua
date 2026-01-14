return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    config = function()
      require('catppuccin').setup()

      -- Load the colorscheme here.
      vim.cmd.colorscheme 'catppuccin-mocha'
    end,
  },
}
