-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- タブ幅を4にする (LazyVimのデフォルトは2)
vim.o.tabstop = 4
vim.o.shiftwidth = 4

-- ------------------------------------------------------------------
-- :terminal で使うシェルを OS ごとに切り替える
--   Windows … PowerShell（pwsh があればそちら、無ければ従来の powershell）
--   Linux   … bash
-- ------------------------------------------------------------------
if vim.fn.has("win32") == 1 then
  -- pwsh (PowerShell 7) の方が起動が速く UTF-8 の扱いも素直なので優先する
  vim.o.shell = vim.fn.executable("pwsh") == 1 and "pwsh" or "powershell"
  vim.o.shellcmdflag = "-NoLogo -ExecutionPolicy RemoteSigned -Command"
  vim.o.shellredir = "-RedirectStandardOutput %s -NoNewWindow -Wait"
  vim.o.shellpipe = "2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode"
  vim.o.shellquote = ""
  vim.o.shellxquote = ""
else
  -- Linux / macOS。上の PowerShell 用の値が残らないよう、既定値へ戻しておく。
  vim.o.shell = vim.fn.executable("bash") == 1 and "bash" or "sh"
  vim.o.shellcmdflag = "-c"
  vim.o.shellredir = ">%s 2>&1"
  vim.o.shellpipe = "2>&1| tee"
  vim.o.shellquote = ""
  vim.o.shellxquote = ""
end

vim.o.swapfile = false
