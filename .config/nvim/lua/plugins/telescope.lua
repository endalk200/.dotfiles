return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.5",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("telescope").setup({
      pickers = {
        find_files = {
          hidden = true,
        },
      },
    })
    local builtin = require("telescope.builtin")

    vim.keymap.set("n", "<leader>ff", builtin.git_files, {})
    vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
    vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
    vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})
    vim.keymap.set("n", "<leader>fr", builtin.registers, {})
    vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, {})
    vim.keymap.set("n", "<leader><leader>", builtin.find_files, {})
    vim.keymap.set("n", "<leader>fo", builtin.oldfiles, {})
    vim.keymap.set("n", "<leader>ss", builtin.lsp_document_symbols, {})
  end,
}
