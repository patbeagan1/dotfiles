-- Leader (set before loading plugins so mappings are correct)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Options from init.vim (converted to Lua)
vim.opt.number = true
vim.opt.encoding = "utf-8"
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.mouse = "a"
vim.opt.termguicolors = true
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.cmdheight = 2
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.backup = true
vim.opt.backupdir = vim.fn.stdpath("config") .. "/backup"
vim.opt.directory = vim.fn.stdpath("config") .. "/swap"
vim.opt.undodir = vim.fn.stdpath("config") .. "/undo"

vim.cmd("syntax enable")
vim.cmd("filetype plugin on")
vim.cmd("filetype indent on")

require("config.lazy")
vim.cmd("colorscheme habamax")
