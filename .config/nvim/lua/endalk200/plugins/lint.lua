return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local lint = require 'lint'
    lint.linters_by_ft = {
      dockerfile = { 'hadolint' },
      github_action = { 'actionlint' },
      markdown = { 'markdownlint' },
      sh = { 'shellcheck' },
      yaml = { 'yamllint' },
    }

    local group = vim.api.nvim_create_augroup('endalk200-lint', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = group,
      callback = function()
        if vim.bo.modifiable then
          lint.try_lint()
        end
      end,
    })
  end,
}
