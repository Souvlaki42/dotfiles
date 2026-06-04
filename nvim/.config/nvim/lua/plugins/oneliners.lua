return {
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
	{ -- Auto complete pairs
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
	{
		"Souvlaki42/tasks.nvim",
		opts = {
			dir_name = "tasks",
			match_header = "TODO:",
		},
		config = function()
			vim.keymap.set("n", "<leader>tc", "<cmd>TasksCreate<cr>", { desc = "Create task from TODO comment" })
			vim.keymap.set("n", "<leader>to", "<cmd>TasksOpen<cr>", { desc = "Open task HUID reference's task file" })
		end,
	},
}
