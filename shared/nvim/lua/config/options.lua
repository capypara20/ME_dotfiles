-- ==================================================================
-- 基本オプション（環境に依らない共通設定）
-- ==================================================================
local opt = vim.opt

-- 行番号
opt.number = true
opt.relativenumber = true

-- インデント（スペース2つ）
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.smartindent = true

-- 表示
opt.wrap = false
opt.termguicolors = true -- 24bitカラー（カラースキームに必須）
opt.signcolumn = "yes"   -- 左端の記号列を常時表示（ガタつき防止）
opt.scrolloff = 8        -- カーソル上下に最低8行残す

-- 検索（小文字なら大小無視、大文字を含めば区別）
opt.ignorecase = true
opt.smartcase = true

-- 編集まわり
opt.clipboard = "unnamedplus" -- OSのクリップボードと共有
opt.undofile = true           -- 終了してもアンドゥ履歴を保持

-- ウィンドウ分割の向き
opt.splitright = true
opt.splitbelow = true
