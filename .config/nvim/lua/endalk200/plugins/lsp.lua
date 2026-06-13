local servers = {
  gopls = {
    settings = {
      gopls = {
        gofumpt = true,
        hints = {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          compositeLiteralTypes = true,
          constantValues = true,
          functionTypeParameters = true,
          parameterNames = true,
          rangeVariableTypes = true,
        },
      },
    },
  },
  rust_analyzer = {},
  ts_ls = {},
  cssls = {},
  tailwindcss = {},
  eslint = {},
  prismals = {},
  dockerls = {},
  docker_compose_language_service = {},
  jsonls = {},
  yamlls = {
    settings = {
      yaml = {
        keyOrdering = false,
        schemaStore = { enable = false, url = '' },
        schemas = {
          kubernetes = {
            'k8s/**/*.yaml',
            'k8s/**/*.yml',
            'kubernetes/**/*.yaml',
            'kubernetes/**/*.yml',
            '*-deployment.yaml',
            '*-service.yaml',
            '*-ingress.yaml',
          },
          ['https://json.schemastore.org/github-workflow.json'] = '.github/workflows/*.{yml,yaml}',
          ['https://json.schemastore.org/github-action.json'] = '.github/actions/*/action.{yml,yaml}',
          ['https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json'] = {
            'docker-compose*.{yml,yaml}',
            'compose*.{yml,yaml}',
          },
        },
      },
    },
  },
  lua_ls = {
    settings = {
      Lua = {
        completion = { callSnippet = 'Replace' },
        diagnostics = { globals = { 'vim' } },
        workspace = { checkThirdParty = false },
      },
    },
  },
}

local tools = {
  'actionlint',
  'biome',
  'black',
  'delve',
  'eslint_d',
  'gofumpt',
  'goimports',
  'hadolint',
  'isort',
  'markdownlint',
  'prettier',
  'shellcheck',
  'shfmt',
  'stylua',
  'yamllint',
}

return {
  'neovim/nvim-lspconfig',
  dependencies = {
    { 'mason-org/mason.nvim', opts = {} },
    'mason-org/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',
    {
      'j-hui/fidget.nvim',
      opts = { notification = { window = { align = 'bottom_right' } } },
    },
    'saghen/blink.cmp',
  },
  config = function()
    vim.lsp.handlers['textDocument/hover'] = function(err, result, ctx, config)
      config = vim.tbl_deep_extend('force', config or {}, {
        border = 'rounded',
        max_height = 25,
        max_width = 100,
      })
      return vim.lsp.handlers.hover(err, result, ctx, config)
    end

    vim.lsp.handlers['textDocument/signatureHelp'] = function(err, result, ctx, config)
      config = vim.tbl_deep_extend('force', config or {}, {
        border = 'rounded',
        max_height = 15,
        max_width = 100,
      })
      return vim.lsp.handlers.signature_help(err, result, ctx, config)
    end

    vim.diagnostic.config {
      severity_sort = true,
      float = { border = 'rounded', source = 'if_many' },
      underline = { severity = vim.diagnostic.severity.ERROR },
      signs = vim.g.have_nerd_font and {
        text = {
          [vim.diagnostic.severity.ERROR] = '󰅚 ',
          [vim.diagnostic.severity.WARN] = '󰀪 ',
          [vim.diagnostic.severity.INFO] = '󰋽 ',
          [vim.diagnostic.severity.HINT] = '󰌶 ',
        },
      } or {},
      virtual_text = { source = 'if_many', spacing = 2 },
    }

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('endalk200-lsp', { clear = true }),
      callback = function(event)
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        local map = function(keys, rhs, desc, mode)
          vim.keymap.set(mode or 'n', keys, rhs, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        map('grn', vim.lsp.buf.rename, 'Rename')
        map('gra', vim.lsp.buf.code_action, 'Code action', { 'n', 'x' })
        map('grr', require('telescope.builtin').lsp_references, 'References')
        map('gri', require('telescope.builtin').lsp_implementations, 'Implementation')
        map('grd', require('telescope.builtin').lsp_definitions, 'Definition')
        map('grD', vim.lsp.buf.declaration, 'Declaration')
        map('gO', require('telescope.builtin').lsp_document_symbols, 'Document symbols')
        map('gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'Workspace symbols')
        map('grt', require('telescope.builtin').lsp_type_definitions, 'Type definition')

        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf) then
          local highlight_group = vim.api.nvim_create_augroup('endalk200-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_group,
            callback = vim.lsp.buf.document_highlight,
          })
          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_group,
            callback = vim.lsp.buf.clear_references,
          })
        end

        if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint, event.buf) then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }, { bufnr = event.buf })
          end, 'Toggle inlay hints')
        end
      end,
    })

    local capabilities = require('blink.cmp').get_lsp_capabilities()
    local ensure_installed = vim.tbl_keys(servers)
    vim.list_extend(ensure_installed, tools)

    require('mason-tool-installer').setup { ensure_installed = ensure_installed }
    require('mason-lspconfig').setup { ensure_installed = vim.tbl_keys(servers), automatic_enable = false }

    for name, config in pairs(servers) do
      config.capabilities = vim.tbl_deep_extend('force', {}, capabilities, config.capabilities or {})
      vim.lsp.config(name, config)
      vim.lsp.enable(name)
    end
  end,
}
