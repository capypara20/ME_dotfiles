-- ==================================================================
-- 共通キーマップ（環境に依らないもの）
--   leader キーは init.lua で <Space> に設定済み
-- ==================================================================
local map = vim.keymap.set

-- 検索ハイライトを消す
map("n", "<leader>nh", "<cmd>nohlsearch<cr>", { desc = "検索ハイライト解除" })

-- 保存・終了
map("n", "<leader>w", "<cmd>write<cr>", { desc = "保存" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "終了" })

-- ウィンドウ間移動（Ctrl + h/j/k/l）
map("n", "<C-h>", "<C-w>h", { desc = "左のウィンドウへ" })
map("n", "<C-j>", "<C-w>j", { desc = "下のウィンドウへ" })
map("n", "<C-k>", "<C-w>k", { desc = "上のウィンドウへ" })
map("n", "<C-l>", "<C-w>l", { desc = "右のウィンドウへ" })
