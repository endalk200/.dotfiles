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
        "goplos",
        "lua_ls",
        "prettier",
        "rubocop",
        -- "ruby_lsp",
        "shfmot",
        -- "solargraph",
        "stylua",
        "tsserver",
        "vtsls",
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
          "lua_ls",
          "tsserver",
          -- "solargraph",
          "gopls",
          "rubocop",
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
      -- lspconfig.solargraph.setup({})
      lspconfig.rubocop.setup({})
      lspconfig.gopls.setup({})

      -- Configure the neovim lsp to show function
      -- documentation on shift k
      vim.keymap.set("n", "K", vim.lsp.buf.hover, {})
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, {})
      vim.keymap.set("n", "gr", vim.lsp.buf.references, {})
      vim.keymap.set("n", "r", vim.lsp.buf.rename, {})
      vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, {})
      vim.keymap.set({ "n", "v" }, "<leader>p", vim.lsp.buf.document_symbol, {})
    end,
  },
}
