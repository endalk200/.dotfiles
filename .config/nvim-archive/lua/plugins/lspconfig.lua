return {
  {
    -- Required to manage installation of language servers
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "eslint_d",
        "gofumpt",
        "goimports-reviser",
        "golines",
        "gopls",
        "lua_ls",
        "prettier",
        "ruby_lsp",
        "shfmot",
        "stylua",
        "tsserver",
        "vtsls",
        "yamlls",
        "tflint",
        "terraformls",
        "markdownlint-cli2",
        "markdown-toc",
      },
    },
    config = function()
      require("mason").setup()
    end,
  },
  {
    -- Required to to add ability to manage language
    -- server installations through lua confgu usin
    -- ensure_installed
    "williamboman/mason-lspconfig.nvim",
    confisong = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "eslint_d",
          "gofumpt",
          "goimports-reviser",
          "golines",
          "gopls",
          "lua_ls",
          "prettier",
          "ruby_lsp",
          "shfmot",
          "stylua",
          "tsserver",
          "vtsls",
          "yamlls",
          "tflint",
          "terraformls",
          "markdownlint-cli2",
          "markdown-toc",
        },
      })
    end,
  },
  {
    -- Neovom language server protocol (LSP) implementation
    -- which enables the editor to communicate with language
    -- servers and deliver code actions and etc
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")

      lspconfig.lua_ls.setup({})
      lspconfig.tsserver.setup({})
      lspconfig.gopls.setup({})
      lspconfig.yamlls.setup({
        settings = {
          yaml = {
            format = {
              enable = true,
              singleQuote = true,
              bracketSpacing = true,
              proseWrap = "preserve",
              printWidth = 80,
              tabSize = 4,
            },
          },
        },
      })
      lspconfig.terraformls.setup({})
      lspconfig.tflint.setup({})

      -- Configure the neovim lsp to show function
      -- documentation on shift k
      vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, {
        desc = "Go to definition",
      })
      vim.keymap.set("n", "gr", vim.lsp.buf.references, {})
      vim.keymap.set("n", "r", vim.lsp.buf.rename, {})
      vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {
        desc = "Code action",
      })
      vim.keymap.set({ "n", "v" }, "<leader>p", vim.lsp.buf.document_symbol, {})
    end,
  },
}
