return {
	"williamboman/mason.nvim",
	dependencies = {
		"mason-org/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		"neovim/nvim-lspconfig", -- enable LSP
	},
	config = function()
		-- import mason
		local mason = require("mason")

		-- import mason-lspconfig
		local mason_lspconfig = require("mason-lspconfig")

		local mason_tool_installer = require("mason-tool-installer")

		-- enable mason and configure icons
		mason.setup({
			ui = {
				icons = {
					package_installed = "✓",
					package_pending = "➜",
					package_uninstalled = "✗",
				},
			},
		})

		mason_lspconfig.setup({
			-- list of servers for mason to install
			ensure_installed = {
				"rust_analyzer",
				-- "tflint",
				"terraformls",
				"gopls",
				"rubocop",
				"prismals",
				-- "tsserver",
				"ts_ls",
				"html",
				"cssls",
				"tailwindcss",
				"eslint",
				"lua_ls",
				"emmet_ls",
				"sqlls",
				"pyright",
				"ruff",
			},
			handlers = {
				-- Default handler for all servers listed in ensure_installed.
				-- Receives the lspconfig server name.
				function(server_name)
					local lspconfig_module = require("lspconfig")
					local capabilities = require("cmp_nvim_lsp").default_capabilities()

					-- Your lspconfig.lua defines a custom 'ts_ls'.
					-- Mason installs 'typescript-language-server', which lspconfig knows as 'tsserver'.
					-- We will set up 'tsserver' normally here. Your 'ts_ls' config will remain separate
					-- and can be used if you have specific keymaps or commands for it.
					lspconfig_module[server_name].setup({
						capabilities = capabilities,
					})
				end,

				-- You can add specific handlers for servers if needed, for example:
				-- ["lua_ls"] = function()
				--   require("lspconfig").lua_ls.setup({ capabilities = capabilities, settings = { ... } })
				-- end,
			},
		})

		-- Create specific handlers for each server
		local lsp_handlers = {}
		for _, server_name in ipairs(servers_to_ensure_installed) do
			lsp_handlers[server_name] = function()
				local server_opts = {
					capabilities = cmp_nvim_lsp.default_capabilities(),
				}
				-- For 'ts_ls', your lspconfig.lua already defines its full configuration,
				-- including capabilities. Calling setup here ensures it's activated
				-- and merges these capabilities if not already set by the primary config.
				-- For other standard servers, this will be their main setup call via mason-lspconfig.
				lspconfig_module[server_name].setup(server_opts)
			end
		end

		require("mason-lspconfig").setup_handlers(lsp_handlers)

		-- Explicitly define setup_handlers
		-- require("mason-lspconfig").setup_handlers({
		-- 	-- Default handler for all servers listed in ensure_installed
		-- 	function(server_name)
		-- 		-- The tsserver -> ts_ls mapping can be useful if mason identifies
		-- 		-- the TypeScript LSP as "tsserver" internally.
		-- 		if server_name == "tsserver" then
		-- 			server_name = "ts_ls"
		-- 		end
		--
		-- 		local capabilities = require("cmp_nvim_lsp").default_capabilities()
		--
		-- 		require("lspconfig")[server_name].setup({
		-- 			capabilities = capabilities,
		-- 		})
		-- 	end,
		-- })

		mason_tool_installer.setup({
			ensure_installed = {
				"gofumpt",
				"goimports-reviser",
				"golines",
				"rubocop",
				"prettier", -- prettier formatter
				"stylua", -- lua formatter
				"black",
				"mypy",
				"tflint",
			},
		})
	end,
}
