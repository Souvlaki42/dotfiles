local M = {}

M.tools = {
  -- LSPs
  { name = "astro-language-server",       lsp_name = "astro",         type = "lsp" },
  { name = "bash-language-server",        lsp_name = "bashls",        type = "lsp" },
  { name = "clangd",                      type = "lsp" },
  { name = "css-lsp",                     lsp_name = "cssls",         type = "lsp" },
  { name = "dockerfile-language-server",  lsp_name = "dockerls",      type = "lsp" },
  { name = "emmet-language-server",       lsp_name = "emmet_ls",      type = "lsp" },
  { name = "eslint-lsp",                  lsp_name = "eslint",        type = "lsp" },
  { name = "gopls",                       type = "lsp" },
  { name = "html-lsp",                    lsp_name = "html",          type = "lsp" },
  { name = "intelephense",                type = "lsp" },
  { name = "json-lsp",                    lsp_name = "jsonls",        type = "lsp" },
  { name = "lua-language-server",         lsp_name = "lua_ls",        type = "lsp" },
  { name = "marksman",                    type = "lsp" },
  { name = "pyright",                     type = "lsp" },
  { name = "rust-analyzer",               lsp_name = "rust_analyzer", type = "lsp" },
  { name = "tailwindcss-language-server", lsp_name = "tailwindcss",   type = "lsp" },
  { name = "typescript-language-server",  lsp_name = "ts_ls",         type = "lsp" },
  { name = "yaml-language-server",        lsp_name = "yamlls",        type = "lsp" },
  { name = "stylua",                      type = "lsp" },

  -- Formatters
  { name = "black",                       builtin = "formatting" },
  { name = "gofumpt",                     builtin = "formatting" },
  { name = "isort",                       builtin = "formatting" },
  { name = "prettierd",                   builtin = "formatting" },
  { name = "stylua",                      builtin = "formatting" },

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

M.treesitter_parsers = {
  "astro",
  "bash",
  "c",
  "cpp",
  "css",
  "dockerfile",
  "go",
  "html",
  "java",
  "javascript",
  "json",
  "lua",
  "markdown",
  "markdown_inline", -- Often needed for full Markdown support
  "php",
  "python",
  "query",
  "rust",
  "tmux",
  "toml",
  "tsx",
  "typescript",
  "vim",
  "vimdoc",
  "yaml",
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

-- Helper function to get a list of names based on their type
function M.get_tool_names_by_type(tool_type)
  local names = {}
  for _, tool in ipairs(M.tools) do
    if tool.type == tool_type then
      table.insert(names, tool.name)
    end
  end
  return names
end

-- Helper function to get LSP names for mason-lspconfig
function M.get_lsp_names()
  local names = {}
  for _, tool in ipairs(M.tools) do
    if tool.type == "lsp" then
      -- Use the specific lsp_name if it exists, otherwise use the package name
      table.insert(names, tool.lsp_name or tool.name)
    end
  end
  return names
end

return M
