return {
	"nvim-telescope/telescope.nvim",
	tag = "0.1.5",
	dependencies = {
		"nvim-lua/plenary.nvim",
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		"nvim-tree/nvim-web-devicons",
		"folke/todo-comments.nvim",
	},
	config = function()
		local telescope = require("telescope")
		local actions = require("telescope.actions")
		local builtin = require("telescope.builtin")

		telescope.setup({
			-- defaults = {
			--   path_display = { "smart" },
			--   mappings = {
			--     i = {
			--       ["<C-k>"] = actions.move_selection_previous,
			--       ["<C-j>"] = actions.move_selection_next,
			--       ["<C-q>"] = actions.send_selected_to_qflist = actions.open_qflist,
			--     }
			--   },
			-- },
			defaults = {
				file_ignore_patterns = {
					"node_modules",
					".git",
				},
			},
			pickers = {
				find_files = {
					hidden = true,
				},
			},
		})

		telescope.load_extension("fzf")

		vim.keymap.set("n", "<leader><leader>", builtin.find_files, {})
		vim.keymap.set("n", "<leader>ff", builtin.git_files, {})
		vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
		vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Find string in cwd" })
		vim.keymap.set("n", "<leader>fG", builtin.grep_string, { desc = "Find string under cursor in cwd" })

		-- TODO: this is a todo
		vim.keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })

		vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})
		vim.keymap.set("n", "<leader>fr", builtin.registers, {})
		vim.keymap.set("n", "<leader>fs", builtin.lsp_document_symbols, {})
		vim.keymap.set("n", "<leader>fo", builtin.oldfiles, {})
		vim.keymap.set("n", "<leader>ss", builtin.lsp_document_symbols, {})
	end,
}
