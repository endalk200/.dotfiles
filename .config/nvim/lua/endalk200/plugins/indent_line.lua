return {
  {
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    ---@module "ibl"
    ---@type ibl.config
    opts = {
      indent = {
        highlight = { 'CursorColumn', 'Whitespace' },
        char = '',
        tab_char = '', -- Specifically handle tabs
      },
      whitespace = {
        highlight = { 'CursorColumn', 'Whitespace' },
        remove_blankline_trail = false,
      },
      scope = { enabled = false },
    },
  },
}
