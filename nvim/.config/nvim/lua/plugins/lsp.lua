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
			if vim.bo.filetype == "oil" then
				return
			end

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
				kset("n", "K", function()
					vim.lsp.buf.hover({ border = "rounded" })
				end, { buffer = event.buf, desc = "Display hover information" })
				kset("n", "gd", vim.lsp.buf.definition, { buffer = event.buf, desc = "Go to definition" })
				kset("n", "gD", vim.lsp.buf.declaration, { buffer = event.buf, desc = "Go to declaration" })
				kset("n", "gi", vim.lsp.buf.implementation, { buffer = event.buf, desc = "Go to implementation" })
				kset("n", "go", vim.lsp.buf.type_definition, { buffer = event.buf, desc = "Go to type definition" })
				kset("n", "gr", vim.lsp.buf.references, { buffer = event.buf, desc = "Go to references" })
				kset("n", "gs", function()
					vim.lsp.buf.signature_help({ border = "rounded" })
				end, { buffer = event.buf, desc = "Display signature help" })
				kset("n", "gl", vim.diagnostic.open_float, { buffer = event.buf, desc = "Open diagnostics float" })
				kset("n", "<F2>", vim.lsp.buf.rename, { buffer = event.buf, desc = "Rename symbol" })
				kset({ "n", "x" }, "<leader>f", format, { buffer = event.buf, desc = "Format document" })
				kset("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = event.buf, desc = "Trigger code actions" })
			end,
		})

		require("mason").setup({})

		require("mason-tool-installer").setup({
			ensure_installed = tools.get_tool_names(),
		})

		require("mason-lspconfig").setup({
			handlers = {
				function(server_name)
					vim.lsp.config[server_name] = {}
					vim.lsp.enable(server_name)
				end,

				lua_ls = function()
					vim.lsp.config["lua_ls"] = {
						cmd = { "lua-language-server" },
						filetypes = { "lua" },
						root_markers = { ".luarc.json", ".git" },
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
					}

					vim.lsp.enable("lua_ls")
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
