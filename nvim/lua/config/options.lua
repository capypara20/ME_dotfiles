-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- タブ幅を4にする (LazyVimのデフォルトは2)
vim.o.tabstop = 4
vim.o.shiftwidth = 4

-- :terminal で PomerShell (pwsh) を起動する
vim.o.shell = "powershell"
vim.o.shellcmdflag = "-NoLogo -ExecutionPolicy RemoteSigned -Command"
vim.o.shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait"
vim.o.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
vim.o.shellquote = ""
vim.o.shellxquote = ""
vim.o.swapfile = false
