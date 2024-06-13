return {
  "stevearc/oil.nvim",
  config = function()
    local oil = require("oil")
    oil.setup({
      columns = {
        "icon",
      },

      delete_to_trash = true,
      skip_confirm_for_simple_edits = true,
      -- Configuration for the floating window in oil.open_float
      float = {
        -- Padding around the floating window
        padding = 2,
        max_width = 0,
        max_height = 0,
        border = "rounded",
        win_options = {
          winblend = 0,
        },
        -- This is the config that will be passed to nvim_open_win.
        -- Change values here to customize the layout
        override = function(conf)
          return conf
        end,
      },
    })

    vim.keymap.set("n", "-", oil.toggle_float, {})
  end,
}
