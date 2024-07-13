return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local config = require("nvim-treesitter.configs")

      config.setup({
        auto_install = true,
        ensure_installed = {
          "bash",
          "html",
          "javascript",
          "json",
          "go",
          "lua",
          "markdown",
          "markdown_inline",
          "python",
          "query",
          "regex",
          "tsx",
          "typescript",
          "ruby",
          "vim",
          "yaml",
          "terraform",
          "hcl",
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- since `vim.tbl_deep_extend`, can only merge tables and not lists, the code above
  -- would overwrite `ensure_installed` with the new value.
  -- If you'd rather extend the default config, use the code below instead:
  --  {
  --    "nvim-treesitter/nvim-treesitter",
  --    opts = function(_, opts)
  --      -- add tsx and treesitter
  --      vim.list_extend(opts.ensure_installed, {
  --        "tsx",
  --        "typescript",
  --      })
  --    end,
  --  },
}
