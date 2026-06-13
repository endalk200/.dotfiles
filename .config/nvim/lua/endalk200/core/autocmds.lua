local group = vim.api.nvim_create_augroup('endalk200-core', { clear = true })

local function set_float_highlights()
  vim.api.nvim_set_hl(0, 'FloatBorder', { link = 'DiagnosticInfo' })
  vim.api.nvim_set_hl(0, 'LspInfoBorder', { link = 'DiagnosticInfo' })
end

set_float_highlights()

vim.api.nvim_create_autocmd('ColorScheme', {
  group = group,
  desc = 'Keep floating window borders visible',
  callback = set_float_highlights,
})

vim.api.nvim_create_autocmd('TextYankPost', {
  group = group,
  desc = 'Highlight yanked text',
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = group,
  desc = 'Use two-space indentation for common web and infra files',
  pattern = {
    'css',
    'dockerfile',
    'html',
    'javascript',
    'javascriptreact',
    'json',
    'lua',
    'prisma',
    'typescript',
    'typescriptreact',
    'yaml',
  },
  callback = function()
    vim.bo.tabstop = 2
    vim.bo.shiftwidth = 2
    vim.bo.expandtab = true
  end,
})

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  group = group,
  desc = 'Detect GitHub Actions workflow files',
  pattern = { '*/.github/workflows/*.yml', '*/.github/workflows/*.yaml' },
  callback = function()
    vim.bo.filetype = 'github_action'
  end,
})

vim.api.nvim_create_autocmd('FileType', {
  group = group,
  desc = 'Use native indentation widths for Go and Rust',
  pattern = { 'go', 'rust' },
  callback = function()
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.expandtab = false
  end,
})
