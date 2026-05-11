local tools = require("core.tools")

return {
	"neovim/nvim-lspconfig",
	dependencies = {
		"williamboman/mason.nvim",
		"williamboman/mason-lspconfig.nvim",
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		-- Autocompletion
		"hrsh7th/nvim-cmp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"saadparwaiz1/cmp_luasnip",
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-nvim-lua",
		-- Snippets
		"L3MON4D3/LuaSnip",
		"rafamadriz/friendly-snippets",
	},
	config = function()
		vim.lsp.inlay_hint.enable(true)

		local function format(args)
			vim.lsp.buf.format({
				formatting_options = { tabSize = 2, insertSpaces = true },
				bufnr = args and (args.buf or args.buffer or nil),
				filter = function(c)
					return c.server_capabilities.documentFormattingProvider
				end,
			})
		end

		vim.api.nvim_create_autocmd("BufWritePre", {
			callback = format,
		})

		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(args)
				vim.lsp.inlay_hint.enable(true, {
					bufnr = args.buf,
				})
			end,
		})

		-- Add borders to floating windows
		vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
		vim.lsp.handlers["textDocument/signatureHelp"] =
			vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })

		-- Configure error/warnings interface
		vim.diagnostic.config({
			virtual_text = true,
			severity_sort = true,
			float = {
				style = "minimal",
				border = "rounded",
				header = "",
				prefix = "",
			},
			signs = {
				text = {
					[vim.diagnostic.severity.ERROR] = "✘",
					[vim.diagnostic.severity.WARN] = "▲",
					[vim.diagnostic.severity.HINT] = "⚑",
					[vim.diagnostic.severity.INFO] = "»",
				},
			},
		})

		-- Add cmp_nvim_lsp capabilities settings to lspconfig
		-- This should be executed before you configure any language server
		local default_capabilities = vim.lsp.protocol.make_client_capabilities()
		vim.lsp.config("*", {
			capabilities = vim.tbl_deep_extend(
				"force",
				default_capabilities,
				require("cmp_nvim_lsp").default_capabilities()
			),
		})

		-- This is where you enable features that only work
		-- if there is a language server active in the file
		vim.api.nvim_create_autocmd("LspAttach", {
			callback = function(event)
				local opts = { buffer = event.buf }

				kset("n", "K", vim.lsp.buf.hover, opts)
				kset("n", "gd", vim.lsp.buf.definition, opts)
				kset("n", "gD", vim.lsp.buf.declaration, opts)
				kset("n", "gi", vim.lsp.buf.implementation, opts)
				kset("n", "go", vim.lsp.buf.type_definition, opts)
				kset("n", "gr", vim.lsp.buf.references, opts)
				kset("n", "gs", vim.lsp.buf.signature_help, opts)
				kset("n", "gl", vim.diagnostic.open_float, opts)
				kset("n", "<F2>", vim.lsp.buf.rename, opts)
				kset({ "n", "x" }, "<leader>f", format, opts)
				kset("n", "<leader>ca", vim.lsp.buf.code_action, opts)
			end,
		})

		require("mason").setup({
			ensure_installed = vim.tbl_map(function(tool)
				return tool.name
			end, tools.tools),
		})

		require("mason-tool-installer").setup({
			ensure_installed = tools.get_lsp_names(),
		})

		require("mason-lspconfig").setup({
			ensure_installed = tools.get_lsp_names(),
			handlers = {
				function(server_name)
					require("lspconfig")[server_name].setup({})
				end,

				lua_ls = function()
					require("lspconfig").lua_ls.setup({
						settings = {
							Lua = {
								runtime = {
									version = "LuaJIT",
								},
								diagnostics = {
									globals = { "vim" },
								},
								workspace = {
									library = { vim.env.VIMRUNTIME },
								},
							},
						},
					})
				end,
			},
		})

		local cmp = require("cmp")

		require("luasnip.loaders.from_vscode").lazy_load()

		vim.opt.completeopt = { "menu", "menuone", "noselect" }

		cmp.setup({
			preselect = "item",
			completion = {
				completeopt = "menu,menuone,noinsert",
			},
			window = {
				documentation = cmp.config.window.bordered(),
			},
			sources = {
				{ name = "path" },
				{ name = "nvim_lsp" },
				{ name = "buffer", keyword_length = 3 },
				{ name = "luasnip", keyword_length = 2 },
			},
			snippet = {
				expand = function(args)
					require("luasnip").lsp_expand(args.body)
				end,
			},
			formatting = {
				fields = { "abbr", "menu", "kind" },
				format = function(entry, item)
					local n = entry.source.name
					if n == "nvim_lsp" then
						item.menu = "[LSP]"
					else
						item.menu = string.format("[%s]", n)
					end
					return item
				end,
			},
			mapping = cmp.mapping.preset.insert({
				-- confirm completion item
				["<CR>"] = cmp.mapping.confirm({ select = false }),

				-- scroll documentation window
				["<C-f>"] = cmp.mapping.scroll_docs(5),
				["<C-u>"] = cmp.mapping.scroll_docs(-5),

				-- toggle completion menu
				["<C-Space>"] = cmp.mapping(function()
					if cmp.visible() then
						cmp.abort()
					else
						cmp.complete()
					end
				end),

				-- tab complete
				["<Tab>"] = cmp.mapping(function(fallback)
					local col = vim.fn.col(".") - 1

					if cmp.visible() then
						cmp.select_next_item({ behavior = "select" })
					elseif col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then
						fallback()
					else
						cmp.complete()
					end
				end, { "i", "s" }),

				-- go to previous item
				["<S-Tab>"] = cmp.mapping.select_prev_item({ behavior = "select" }),

				-- navigate to next snippet placeholder
				["<C-d>"] = cmp.mapping(function(fallback)
					local luasnip = require("luasnip")

					if luasnip.jumpable(1) then
						luasnip.jump(1)
					else
						fallback()
					end
				end, { "i", "s" }),

				-- navigate to the previous snippet placeholder
				["<C-b>"] = cmp.mapping(function(fallback)
					local luasnip = require("luasnip")

					if luasnip.jumpable(-1) then
						luasnip.jump(-1)
					else
						fallback()
					end
				end, { "i", "s" }),
			}),
		})
	end,
}
