return {
  { -- Git plugin
    "tpope/vim-fugitive",
  },
  { -- Show historical versions of the file locally
    "mbbill/undotree",
  },
  {
    -- Required for other plugins to function
    "nvim-lua/plenary.nvim",
  },
  { -- Show CSS Colors
    "brenoprata10/nvim-highlight-colors",
    config = function()
      require("nvim-highlight-colors").setup({})
    end,
  },
  { -- Auto complete pars
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local npairs = require("nvim-autopairs")
      npairs.setup({})
    end,
  },
  { -- Which key
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
  },
}
