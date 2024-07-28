-- TODO: create
return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		dependencies = {
			"windwp/nvim-ts-autotag",
		},
		config = function()
			local config = require("nvim-treesitter.configs")

			config.setup({
				auto_install = false,
				-- enable auto tagging (w/ nvim-ts-autotag plugin)
				autotag = {
					enable = true,
				},
				ensure_installed = {
					"helm",
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
					"http",
					"prisma",
				},
				highlight = { enable = true },
				indent = { enable = true },
				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "<C-space>",
						node_incremental = "<C-space>",
						scope_incremental = false,
						node_decremental = "<bs>",
					},
				},
			})
		end,
	},
}
