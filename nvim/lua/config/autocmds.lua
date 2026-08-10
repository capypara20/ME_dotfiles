-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Insert/Terminalモードを抜けてNormalモードに戻ったらIMEをオフにする
-- Windows: config/bin/zenhan32.exe を使用 (半角英数=IMEオフ状態にする)
-- Linux: fcitx5 か ibus があればそちらを使用 (環境に合わせて要調整)
local function ime_off()
  if vim.fn.has("win32") == 1 then
    local zenhan = vim.fn.stdpath("config") .. "/bin/zenhan-32.exe"
    if vim.fn.filereadable(zenhan) == 1 then
      vim.fn.system({ zenhan, "0" })
    end
  elseif vim.fn.has("unix") == 1 then
    if vim.fn.executable("fcitx5-remote") == 1 then
      vim.fn.system({ "fcitx5-remote", "-c" })
    elseif vim.fn.executable("ibus") == 1 then
      vim.fn.system({ "ibus", "engine", "xkb:us::eng" })
    end
  end
end

vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = { "i:n", "ic:n", "t:n" },
  callback = ime_off,
  desc = "Insert/TerminalモードからNormalモードに戻ったらIMEをオフにする",
})
