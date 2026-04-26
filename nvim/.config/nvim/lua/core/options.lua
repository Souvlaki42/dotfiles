--line nums
vim.opt.relativenumber = true
vim.opt.number = true

-- indentation and tabs
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.autoindent = true
vim.opt.expandtab = true

-- search settings
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- appearance
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.opt.signcolumn = "yes"
vim.opt.fillchars = { eob = " " }

-- cursor line
vim.opt.cursorline = true

-- clipboard
vim.opt.clipboard:append("unnamedplus")

-- backspace
vim.opt.backspace = "indent,eol,start"

-- split windows
vim.opt.splitbelow = true
vim.opt.splitright = true

-- dw/diw/ciw works on full-word
vim.opt.iskeyword:append("-")

-- keep cursor at least 8 rows from top/bot
vim.opt.scrolloff = 8

-- undo dir settings
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- incremental search
vim.opt.incsearch = true

-- faster cursor hold
vim.opt.updatetime = 50
