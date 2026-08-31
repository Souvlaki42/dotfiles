return {
	"romus204/tree-sitter-manager.nvim",
	config = function()
		require("tree-sitter-manager").setup({
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
