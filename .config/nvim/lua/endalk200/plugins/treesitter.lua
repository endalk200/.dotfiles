local parsers = {
  'bash',
  'c',
  'css',
  'diff',
  'dockerfile',
  'go',
  'gomod',
  'gosum',
  'gowork',
  'html',
  'javascript',
  'jsdoc',
  'json',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'prisma',
  'query',
  'rust',
  'tsx',
  'typescript',
  'vim',
  'vimdoc',
  'yaml',
}

local filetypes = {
  'bash',
  'c',
  'css',
  'diff',
  'dockerfile',
  'go',
  'gomod',
  'gosum',
  'gowork',
  'html',
  'javascript',
  'javascriptreact',
  'json',
  'jsonc',
  'lua',
  'markdown',
  'prisma',
  'rust',
  'tsx',
  'typescript',
  'typescriptreact',
  'vim',
  'vimdoc',
  'yaml',
}

return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter').setup {
      install_dir = vim.fn.stdpath 'data' .. '/site',
    }

    require('nvim-treesitter').install(parsers)

    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('endalk200-treesitter', { clear = true }),
      pattern = filetypes,
      callback = function(event)
        pcall(vim.treesitter.start, event.buf)

        if vim.bo[event.buf].filetype ~= 'go' then
          vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
