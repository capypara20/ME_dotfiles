-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- ------------------------------------------------------------------
-- Insert/Terminal モードを抜けたら IME を自動でオフにする
--
--   Windows … 同梱の bin/zenhan-*.exe を呼ぶ
--   WSL     … IME を持っているのは Windows 側なので、同じく zenhan.exe を呼ぶ
--              （WSL からは Windows の exe をそのまま実行できる）
--   素のLinux … fcitx5 か ibus を使う
--
-- ※ Esc のたびに外部プログラムを起動するので、jobstart で「投げっぱなし」に
--    して待たないようにしている。vim.fn.system だと終わるまで固まる。
-- ------------------------------------------------------------------

-- 同梱の zenhan を探す（64bit 版を優先）
local function find_zenhan()
  local dir = vim.fn.stdpath("config") .. "/bin/"
  for _, exe in ipairs({ "zenhan-64.exe", "zenhan-32.exe" }) do
    if vim.fn.filereadable(dir .. exe) == 1 then
      return dir .. exe
    end
  end
  return nil
end

-- 待たずに実行する小さなヘルパー
local function run_async(cmd)
  vim.fn.jobstart(cmd, { detach = true })
end

local function ime_off()
  -- Windows 本体、または WSL（IME は Windows 側が持っている）
  if vim.fn.has("win32") == 1 or vim.fn.has("wsl") == 1 then
    local zenhan = find_zenhan()
    if zenhan then
      run_async({ zenhan, "0" })
    end
  -- 素の Linux（WSL ではない）
  elseif vim.fn.has("unix") == 1 then
    if vim.fn.executable("fcitx5-remote") == 1 then
      run_async({ "fcitx5-remote", "-c" })
    elseif vim.fn.executable("ibus") == 1 then
      run_async({ "ibus", "engine", "xkb:us::eng" })
    end
  end
end

vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = { "i:n", "ic:n", "t:n" },
  callback = ime_off,
  desc = "Insert/TerminalモードからNormalモードに戻ったらIMEをオフにする",
})
