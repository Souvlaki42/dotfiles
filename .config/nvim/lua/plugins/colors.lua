return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    opts = {},
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      auto_integrations = true,
      flavour = "mocha",
    },
    config = function()
      vim.cmd.colorscheme("catppuccin-nvim")
    end,
  },
}
