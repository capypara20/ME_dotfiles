-- ~/.config/nvim/init.lua
-- ==================================================================
-- neovim 設定のエントリポイント（共通の土台）
--
-- ここには「OSにも環境(仕事/プライベート)にも依らない共通設定」だけを置く。
-- 仕事/プライベートで変えたい差分は、末尾の require("profile") で読み込む。
--   profile.lua の実体は install 時に
--   profiles/<work|private>/nvim/profile.lua へのリンクとして作られる。
-- ==================================================================

-- リーダーキーはプラグイン読み込みより前に決めておく必要がある
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("config.options") -- 基本オプション
require("config.keymaps") -- 共通キーマップ
require("config.lazy")    -- プラグインマネージャ(lazy.nvim)を起動

-- ------------------------------------------------------------------
-- 環境固有の上書き（無くてもエラーにしない）
-- profiles/<work|private>/nvim/profile.lua が install 時にリンクされる
-- ------------------------------------------------------------------
pcall(require, "profile")
