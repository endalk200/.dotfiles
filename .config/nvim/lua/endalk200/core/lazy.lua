local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'

if not vim.uv.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end

vim.opt.rtp:prepend(lazypath)

require('lazy').setup(require 'endalk200.plugins', {
  checker = { enabled = true, notify = false },
  change_detection = { notify = false },
  install = { colorscheme = { 'catppuccin-mocha' } },
  ui = {
    border = 'rounded',
    icons = vim.g.have_nerd_font and {} or {
      cmd = 'cmd',
      config = 'config',
      event = 'event',
      ft = 'ft',
      init = 'init',
      keys = 'keys',
      plugin = 'plugin',
      runtime = 'runtime',
      source = 'source',
      start = 'start',
      task = 'task',
      lazy = 'lazy',
    },
  },
})
