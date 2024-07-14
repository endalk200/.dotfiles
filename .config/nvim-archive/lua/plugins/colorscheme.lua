return {
  --  {
  --    "navarasu/onedark.nvim",
  --    name = "onedark",
  --    priority = 1000,
  --    config = function()
  --      require("onedark").setup({
  --        style = "cool",
  --      })
  --
  --      require("onedark").load()
  --
  --      vim.cmd.colorscheme("onedark")
  --    end,
  --  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        background = {
          dark = "mocha",
          light = "mocha",
        },
        default_integrations = true,
        integrations = {
          cmp = true,
          gitsigns = true,
          nvimtree = true,
          treesitter = true,
          notify = true,
          neotree = true,
          noice = true,
          mason = true,
          mini = {
            enabled = true,
            indentscope_color = "",
          },
        },
      })

      vim.opt.wrap = true
      vim.opt.termguicolors = true
      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
