local function biome_or_prettier(prettier_formatters)
  return function(bufnr)
    if vim.fs.root(bufnr, { 'biome.json', 'biome.jsonc' }) then
      return { 'biome' }
    end

    return prettier_formatters
  end
end

return { -- Autoformat
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- Disable "format_on_save lsp_fallback" for languages that don't
      -- have a well standardized coding style. You can add additional
      -- languages here or re-enable it for the disabled ones.
      local disable_filetypes = { c = true, cpp = true }
      local filetype = vim.bo[bufnr].filetype

      if disable_filetypes[filetype] then
        return nil
      else
        return {
          timeout_ms = 1000,
          lsp_format = 'fallback',
        }
      end
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
      go = { 'goimports', 'gofumpt' },
      rust = { 'rustfmt' },
      prisma = { 'prisma' },
      -- Conform can also run multiple formatters sequentially
      python = { 'isort', 'black' },

      typescript = biome_or_prettier { 'prettier' },
      -- You can use 'stop_after_first' to run the first available formatter from the list
      javascript = biome_or_prettier { 'prettierd', 'prettier', stop_after_first = true },
      javascriptreact = biome_or_prettier { 'prettier' },
      typescriptreact = biome_or_prettier { 'prettier' },
      css = biome_or_prettier { 'prettier' },
      html = biome_or_prettier { 'prettier' },
      json = biome_or_prettier { 'prettier' },
      jsonc = biome_or_prettier { 'prettier' },
      yaml = { 'prettier' },
      markdown = { 'prettier' },
      sh = { 'shfmt' },
      bash = { 'shfmt' },

      hcl = { 'packer_fmt' },
      terraform = { 'terraform_fmt' },
      tf = { 'terraform_fmt' },
      ['terraform-vars'] = { 'terraform_fmt' },

      ruby = { 'solargraph' },
    },
  },
}
