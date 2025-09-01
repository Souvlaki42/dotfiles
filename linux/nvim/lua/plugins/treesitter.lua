return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
        local configs = require("nvim-treesitter.configs")
        configs.setup({
            highlight = {
                enable = true,
            },
            indent = { enable = true },
            autotage = { enable = true },
            ensure_installed = {
                "lua",
                "tsx",
                "typescript",
                "python",
                "go",
                "rust",
                "astro",
                "java",
                "php",
                "markdown",
                "c",
                "cpp",
                "vim",
                "vimdoc",
                "query"
            },
            auto_install = true,
        })
    end
}
