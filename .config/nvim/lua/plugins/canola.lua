return {
	"barrettruth/canola.nvim",
	branch = "canola",
	dependencies = { "nvim-tree/nvim-web-devicons", "barrettruth/canola-collection" },
	init = function()
		function _G.get_canola_winbar()
			local bufnr = vim.api.nvim_win_get_buf(vim.g.statusline_winid)
			local dir = require("canola").get_current_dir(bufnr)
			if dir then
				return vim.fn.fnamemodify(dir, ":~")
			else
				-- If there is no current directory (e.g. over ssh), just show the buffer name
				return vim.api.nvim_buf_get_name(0)
			end
		end

		local function get_line_range()
			local mode = vim.fn.mode()

			if mode == "n" then
				local line = vim.api.nvim_win_get_cursor(0)[1]
				return line, line
			end

			if mode == "v" or mode == "V" or mode == "\22" then
				-- \22 is CTRL-V, i.e. blockwise Visual mode
				local start_line = vim.fn.line("v")
				local end_line = vim.fn.line(".")

				return math.min(start_line, end_line), math.max(start_line, end_line)
			end

			return nil, nil
		end

		local function run_command()
			local first, last = get_line_range()
			local bufnr = vim.api.nvim_win_get_buf(0)

			if first == nil or last == nil then
				print("No selected lines")
				return
			end

			local filenames = {}
			for linum = first, last do
				local entry = require("canola").get_entry_on_line(bufnr, linum)
				if entry == nil then
					print(string.format("Line %d on buffer %d has no entry", linum, bufnr))
					goto continue
				end
				local name = entry.parsed_name
				if name == nil then
					print("This entry has no name")
					goto continue
				end
				table.insert(filenames, name)
				::continue::
			end

			vim.ui.input({ prompt = "Give command: " }, function(input)
				if input == nil or string.gsub(input, " ", "") == "" then
					return
				end

				for _, name in ipairs(filenames) do
					local command = string.gsub(input, "%%", function()
						return vim.fn.shellescape(name)
					end)

					local result = vim.system({
						vim.o.shell,
						vim.o.shellcmdflag,
						command,
					}, {
						text = true,
					}):wait()

					print(result.stdout, result.stderr)
				end
			end)
		end

		vim.g.canola_trash = {}

		vim.g.canola = {
			columns = {
				"icon",
				"permissions",
				"owner",
				"group",
				"size",
				"type",
				"mtime",
			},
			confirm = "delete",
			cursor = true,
			hidden = {
				enabled = false,
				always = {},
			},
			keymaps = {
				["gc"] = {
					desc = "Execute a shell command on the selected entry",
					mode = { "n", "v" },
					callback = run_command,
				},
				["q"] = {},
			},
			sort = {
				by = { { "type", "asc" }, { "name", "asc" } },
				ignore_case = false,
				natural = true,
			},
			watch = true,
			win = {
				concealcursor = "nvic",
				conceallevel = 3,
				cursorcolumn = false,
				foldcolumn = "0",
				list = false,
				signcolumn = "no",
				spell = false,
				winbar = "%!v:lua.get_canola_winbar()",
				wrap = true,
			},
		}

		vim.api.nvim_create_autocmd("BufEnter", {
			pattern = "canola://*",
			callback = function()
				local dir = require("canola").get_current_dir()
				if dir then
					vim.cmd.lcd(dir)
				end
			end,
		})
	end,
}
