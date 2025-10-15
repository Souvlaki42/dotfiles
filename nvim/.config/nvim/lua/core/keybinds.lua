-- KEYBINDS
vim.g.mapleader = " "

kset("n", "<M-j>", ":m .+1<CR>==") -- move line up(n)
kset("n", "<M-k>", ":m .-2<CR>==") -- move line down(n)
kset("v", "<M-j>", ":m '>+1<CR>gv=gv") -- move line up(v)
kset("v", "<M-k>", ":m '<-2<CR>gv=gv") -- move line down(v)

kset("n", "J", "mzJ`z") -- Remap joining lines
kset("n", "<C-d>", "<C-d>zz") -- Keep cursor in place while moving up/down page
kset("n", "<C-u>", "<C-u>zz")
kset("n", "n", "nzzzv") -- center screen when looping search results
kset("n", "N", "Nzzzv")

-- paste and don't replace clipboard over deleted text
kset("x", "<leader>p", [["_dP]])
kset({ "n", "v" }, "<leader>d", [["_d]])

-- sometimes in insert mode, control-c doesn't exactly work like escape
kset("i", "<C-c>", "<Esc>")

kset("n", "<C-k>", "<cmd>cnext<CR>zz")
kset("n", "<C-j>", "<cmd>cprev<CR>zz")

-- What the heck is Ex mode?
kset("n", "Q", "<nop>")

kset("n", "<leader>k", "<cmd>lnext<CR>zz")
kset("n", "<leader>j", "<cmd>lprev<CR>zz")

-- make file executable
kset("n", "<leader>x", "<cmd>!chmod +x %<CR>")

-- open undo tree
kset("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Undo tree" })

-- toggle file explorer
kset("n", "-", "<CMD>Oil --float<CR>", { desc = "Open parent directory" })
