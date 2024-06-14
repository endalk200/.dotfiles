return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "nvimtools/none-ls-extras.nvim", -- eslint_d
  },
  config = function()
    local null_ls = require("null-ls")
    -- local autogroup = vim.api.nvim_create_augroup("LspFormating", {})

    null_ls.setup({
      sources = {
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.rubocop,
        --  null_ls.builtins.formatting.solargraph,
        null_ls.builtins.formatting.prettier,
        -- The following formatters are going to be installed via Mason
        -- This will expose some commands that formatts fo code.
        -- Hoever it does not autoformat like the other formatters thus we need
        -- to implement the autoformatting logic. Thus the on_attach directive
        -- below
        null_ls.builtins.formatting.gofmt,
        null_ls.builtins.formatting.goimports_reviser,
        null_ls.builtins.formatting.golines,
        --  null_ls.builtins.diagnostics.eslint_d
        -- null_ls.builtins.diagnostics.solargraph,
        null_ls.builtins.diagnostics.rubocop,
        require("none-ls.diagnostics.eslint_d"),
      },

      --      on_attach = function(client, bufnr)
      --        if client.supports_method("textDocument/formatting") then
      --          vim.api.nvim_clear_autocmds({
      --            group = autogroup,
      --            buffer = bufnr,
      --          })
      --
      --          vim.api.nvim_create_autocmd("BufWritePre", {
      --            group = autogroup,
      --            buffer = bufnr,
      --            callback = function()
      --              vim.lsp.buf.format({
      --                bufnr = bufnr,
      --              })
      --            end,
      --          })
      --        end
      --      end,
    })

    vim.keymap.set("n", "<leader>fo", vim.lsp.buf.format, {})
  end,
}
