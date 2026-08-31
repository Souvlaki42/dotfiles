local M = {}

M.tools = {
	-- LSPs
	{ name = "astro-language-server", mason_name = "astro", lsp = true },
	{ name = "bash-language-server", mason_name = "bashls", lsp = true },
	{ name = "clangd", lsp = true },
	{ name = "css-lsp", mason_name = "cssls", lsp = true },
	{ name = "dockerfile-language-server", mason_name = "dockerls", lsp = true },
	{ name = "docker-compose-language-service", mason_name = "docker_compose_language_service", lsp = true },
	{ name = "docker-language-server", mason_name = "docker_language_server", lsp = true },
	{ name = "emmet-language-server", mason_name = "emmet_ls", lsp = true },
	{ name = "eslint-lsp", mason_name = "eslint", lsp = true },
	{ name = "gopls", lsp = true },
	{ name = "html-lsp", mason_name = "html", lsp = true },
	{ name = "intelephense", lsp = true },
	{ name = "json-lsp", mason_name = "jsonls", lsp = true },
	{ name = "lua-language-server", mason_name = "lua_ls", lsp = true },
	{ name = "marksman", lsp = true },
	{ name = "pyright", lsp = true },
	{ name = "rust-analyzer", mason_name = "rust_analyzer", lsp = true },
	{ name = "tailwindcss-language-server", mason_name = "tailwindcss", lsp = true },
	{ name = "typescript-language-server", mason_name = "ts_ls", lsp = true },
	{ name = "yaml-language-server", mason_name = "yamlls", lsp = true },
	{ name = "stylua", lsp = true },
	{ name = "jdtls", lsp = true },
	{ name = "taplo", lsp = true },

	-- Formatters
	{ name = "black", builtin = "formatting" },
	{ name = "gofumpt", builtin = "formatting" },
	{ name = "isort", builtin = "formatting" },
	{ name = "prettierd", builtin = "formatting" },
	{ name = "stylua", builtin = "formatting" },
	{
		name = "google_java_format",
		builtin = "formatting",
		mason_name = "google-java-format",
	},

	-- Linters
	{
		name = "eslint_d",
		require_paths = {
			"none-ls.diagnostics.eslint_d",
			"none-ls.formatting.eslint_d",
			"none-ls.code_actions.eslint_d",
		},
	},
	{
		name = "shellcheck",
		require_paths = { "none-ls-shellcheck.diagnostics", "none-ls-shellcheck.code_actions" },
	},
}

-- Helper function to convert a list of tools into a list of sources for none-ls
function M.get_none_ls_sources()
	local null_ls = require("null-ls")
	local sources = {}

	for _, tool in ipairs(M.tools) do
		if tool.builtin then
			local builtin_category = null_ls.builtins[tool.builtin]
			if builtin_category then
				local source = builtin_category[tool.name]
				if source then
					table.insert(sources, source)
				end
			end
		elseif tool.require_paths then
			for _, path in ipairs(tool.require_paths) do
				local success, required_source = pcall(require, path)
				if success then
					table.insert(sources, required_source)
				else
					vim.notify("none-ls: failed to require source from " .. path, vim.log.levels.WARN)
				end
			end
		end
	end

	return sources
end

-- Helper function to get Mason names
function M.get_tool_names()
	local names = {}
	for _, tool in ipairs(M.tools) do
		table.insert(names, tool.mason_name or tool.name)
	end
	return names
end

return M
