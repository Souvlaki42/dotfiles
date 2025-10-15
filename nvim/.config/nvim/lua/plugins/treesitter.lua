local tools = require("core.tools")
return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    local configs = require("nvim-treesitter.configs")
    configs.setup({
      highlight = { enable = true },
      indent = { enable = true },
      autotage = { enable = true },
      sync_install = false,
      auto_install = true,
      ensure_installed = tools.treesitter_parsers,
    })
  end
}
