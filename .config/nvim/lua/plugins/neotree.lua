return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
      "MunifTanjim/nui.nvim",
      -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
    },
    config = function()
      vim.keymap.set("n", "<leader>E", "<Cmd>Neotree focus<CR>", {})
      -- vim.keymap.set("n", "<leader>bf", "<Cmd>Neotree buffers reveal float<CR>", {})
      vim.keymap.set("n", "<leader>e", "<Cmd>Neotree toggle float<CR>", {})
    end,
  },
}