return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")

		harpoon:setup({
			global_settings = {
				save_on_toggle = false,

				save_on_change = true,

				tmux_autoclose_windows = false,

				exclude_filetypes = { "harpoon" },

				mark_branch = true,

				tabline = false,
				tabline_prefix = " ",
				tabline_sufix = " ",
			},
		})

		local conf = require("telescope.config").values
		local function toggle_telescope(harpoon_files)
			local file_paths = {}
			for _, item in ipairs(harpoon_files.items) do
				table.insert(file_paths, item.value)
			end

			require("telescope.pickers")
				.new({}, {
					prompt_title = "Harpoon",
					finder = require("telescope.finders").new_table({
						results = file_paths,
					}),
					previewer = conf.file_previewer({}),
					sorter = conf.generic_sorter({}),
				})
				:find()
		end

		vim.keymap.set("n", "<leader>ha", function()
			toggle_telescope(harpoon:list())
		end, { desc = "Open harpoon window" })
		vim.keymap.set("n", "<leader>hx", function()
			harpoon:list():add()
		end, { desc = "Add current file to harpoon" })
		vim.keymap.set("n", "<leader>hd", function()
			harpoon:list():remove()
		end, { desc = "Remove the current file from harpoon list" })
		vim.keymap.set("n", "<leader>hc", function()
			harpoon:list():clear()
		end, { desc = "Clear harpoon list" })
		vim.keymap.set("n", "<leader>hn", function()
			harpoon:list():next()
		end, { desc = "Go to the next item on harpoon list" })
		vim.keymap.set("n", "<leader>hp", function()
			harpoon:list():prev()
		end, { desc = "Go to the previous item on harpoon list" })
	end,
}
