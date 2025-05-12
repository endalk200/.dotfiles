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
			-- local ft_to_parser = require("nvim-treesitter.parsers").filetype_to_parsername
			--
			-- ft_to_parser.mdx = "markdown"

			config.setup({
				auto_install = false,
				-- enable auto tagging (w/ nvim-ts-autotag plugin)
				-- autotag = {
				-- 	enable = true,
				-- },
				ensure_installed = {
					"helm",
					"bash",
					"html",
					"javascript",
					"json",
					"go",
					"sql",
					"lua",
					"markdown",
					"markdown_inline",
					"python",
					"hurl",
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
