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

-- Move window focus around --
kset("n", "<C-h>", "<C-w>h", { desc = "Move window focus left" })
kset("n", "<C-j>", "<C-w>j", { desc = "Move window focus down" })
kset("n", "<C-k>", "<C-w>k", { desc = "Move window focus up" })
kset("n", "<C-l>", "<C-w>l", { desc = "Move window focus right" })

-- toggle file explorer
kset("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
