return {
	"barrettruth/canola.nvim", -- TODO: maybe switch back to oil if needed
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local oil = require("oil")

		function _G.get_oil_winbar()
			local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
			local dir = require("oil").get_current_dir(bufnr)
			if dir then
				return vim.fn.fnamemodify(dir, ":~")
			else
				-- If there is no current directory (e.g. over ssh), just show the buffer name
				return vim.api.nvim_buf_get_name(0)
			end
		end

		oil.setup({
			default_file_explorer = true,
			delete_to_trash = true,
			skip_confirm_for_simple_edits = true,
			columns = {
				"icon",
				"permissions",
				"owner",
				"group",
				"size",
				"mtime",
			},
			view_options = {
				show_hidden = true,
				natural_order = true,
				is_always_hidden = function(name)
					return string.find(name, "..", 0, true)
				end,
			},
			win_options = {
				winbar = "%!v:lua.get_oil_winbar()",
				wrap = true,
			},
			watch_for_changes = true,
			keymaps = {
				["gc"] = {
					callback = function()
						local entry = oil.get_cursor_entry()
						if entry == nil then
							print("No entry is here")
							return
						end

						local name = entry.parsed_name
						if name == nil then
							print("No entry name")
							return
						end

						vim.ui.input({ prompt = "Give command: " }, function(input)
							if input == nil or string.gsub(input, " ", "") == "" then
								return
							end
							local command = string.gsub(input, "%%", name)
							print(vim.fn.system(command))
						end)
					end,
					mode = "n",
					desc = "Execute a shell command on the selected entry",
				},
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
