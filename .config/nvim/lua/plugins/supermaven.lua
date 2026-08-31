return {
	"supermaven-inc/supermaven-nvim",
	config = function()
		require("supermaven-nvim").setup({
			keymaps = {
				accept_suggestion = "<A-l>",
				clear_suggestion = "<C-]>",
				accept_word = "<A-k>",
			},
		})
	end,
}
