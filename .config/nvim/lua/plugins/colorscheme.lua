return {
  {
    "navarasu/onedark.nvim",
    name = "onedark",
    priority = 1000,
    config = function()
      require("onedark").setup({
        style = "cool",
      })

      require("onedark").load()

      vim.cmd.colorscheme("onedark")
    end,
  },
  --  {
  --    "catppuccin/nvim",
  --    name = "catppuccin",
  --    lazy = false,
  --    priority = 1000,
  --    config = function()
  --      vim.cmd.colorscheme("catppuccin-mocha")
  --    end,
  --  },
}
