return {
  "ej-shafran/compile-mode.nvim",
  version = "^5.0.0",
  branch = "latest",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "m00qek/baleia.nvim", tag = "v1.3.0", submodules = false },
  },
  config = function()
    vim.g.compile_mode = {
      baleia_setup = true,
      default_command = "",
    }

    vim.keymap.set("n", "<leader>cc", "<cmd>Compile<cr>", { desc = "Compile: run command" })
    vim.keymap.set("n", "<leader>cr", "<cmd>Recompile<cr>", { desc = "Compile: rerun last" })
    vim.keymap.set("n", "]e", "<cmd>NextError<cr>", { desc = "Compile: next error" })
    vim.keymap.set("n", "[e", "<cmd>PrevError<cr>", { desc = "Compile: prev error" })
  end,
}
