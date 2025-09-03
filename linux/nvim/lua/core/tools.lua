-- lua/core/tools.lua

local M = {}

-- This is our Single Source of Truth for all installed tools.
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

  -- Linters
  { name = "eslint_d",                    type = "linter" },
  { name = "shellcheck",                  type = "linter" },

  -- Formatters
  { name = "black",                       type = "formatter" },
  { name = "gofumpt",                     type = "formatter" },
  { name = "isort",                       type = "formatter" },
  { name = "prettierd",                   type = "formatter" },
  { name = "stylua",                      type = "formatter" },
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
