return {
	"lukas-reineke/indent-blankline.nvim",
	main = "ibl",
	opts = function(_, opts)
		return {
			-- indent = { char = "|" },
		}
		-- return require("indent-rainbowline").make_opts(opts, {
		-- 	indent = { char = "|" },
		-- 	-- How transparent should the rainbow colors be. 1 is completely opaque, 0 is invisible. 0.07 by default
		-- 	color_transparency = 0.03,
		-- })
	end,
	-- dependencies = {
	-- 	"TheGLander/indent-rainbowline.nvim",
	-- },
}
