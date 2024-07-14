-- TODO: Configure bufferline correctly
return {
	"akinsho/bufferline.nvim",
	version = "*",
	dependencies = "nvim-tree/nvim-web-devicons",
	event = "VeryLazy",
	config = function()
		require("bufferline").setup({
			options = {
				mode = "buffers",
				-- diagnostics = 'coc',
				offsets = {
					{
						filetype = "NvimTree",
						text = "File Explorer",
						highlight = "Directory",
						separator = true,
					},
				},
			},
		})
	end,
}
