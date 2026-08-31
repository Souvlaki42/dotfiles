return {
  "nvimtools/none-ls.nvim",
  dependencies = {
    "nvimtools/none-ls-extras.nvim",
    "gbprod/none-ls-shellcheck.nvim",
  },
  config = function()
    local null_ls = require("null-ls")
    local tools = require("core.tools")

    null_ls.setup({
      sources = tools.get_none_ls_sources(),
    })
  end,
}
