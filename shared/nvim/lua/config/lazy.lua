-- ==================================================================
-- lazy.nvim（プラグインマネージャ）の自動インストール＆起動
--   lua/plugins/ 配下の *.lua を「プラグイン定義」として読み込む。
--   新しいプラグインを入れたいときは lua/plugins/ にファイルを足すだけ。
-- ==================================================================

-- 初回起動時、lazy.nvim 本体が無ければ自動で clone する
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { import = "plugins" }, -- lua/plugins/ 配下をすべて読み込む
}, {
  change_detection = { notify = false }, -- 設定変更の通知はうるさいので切る
})
