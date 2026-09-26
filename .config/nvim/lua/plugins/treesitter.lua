return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		local treesitter = require("nvim-treesitter")
		treesitter.setup({
			highlight = { enable = true },
			indent = { enable = true },
			autotage = { enable = true },
			sync_install = false,
			auto_install = true,
			ensure_installed = {
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
				"regex",
			},
		})
	end,
}
