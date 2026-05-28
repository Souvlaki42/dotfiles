return {
	"stevearc/oil.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local oil = require("oil")

		oil.setup({
			default_file_explorer = true,
			delete_to_trash = true,
			skip_confirm_for_simple_edits = true,
			columns = {
				"icon",
				"permissions",
				"size",
				"mtime",
			},
			view_options = {
				show_hidden = true,
				natural_order = true,
				is_always_hidden = function(name)
					return name == ".git" or name == "." or name == "../"
				end,
			},
			win_options = {
				wrap = true,
			},
		})

		vim.api.nvim_create_autocmd("BufEnter", {
			pattern = "oil://*",
			callback = function()
				local dir = oil.get_current_dir()
				if dir then
					vim.cmd.lcd(dir)
				end
			end,
		})
	end,
}
