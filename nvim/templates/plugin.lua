-- ============================================================
--  プラグイン追加用テンプレート
-- ============================================================
--  使い方:
--    1. このファイルを lua/plugins/<カテゴリ>/ にコピーする
--       例) cp templates/plugin.lua lua/plugins/editor/40_foo.lua
--    2. 不要な行を消して書き換える
--    3. nvim を再起動して :Lazy sync
--
--  ※ このファイル自体は lua/ の外にあるので lazy.nvim には
--     読み込まれない。安全に書き換えて構わない。
--
--  カテゴリと番号の付け方:
--    lsp/     … 言語サーバ・LSP関連
--    editor/  … 補完・編集操作
--    ui/      … 見た目・ステータスライン
--    tools/   … ファイラー・その他ツール
--    番号は 10, 20, 30 と10刻み（間に割り込ませる余地を残すため）
-- ============================================================

return {
  {
    -- GitHub の "ユーザー名/リポジトリ名" を書く（必須）
    "author/plugin.nvim",

    -- ---------- 読み込むタイミング（どれか1つ以上） ----------
    -- event = "VeryLazy",              -- 起動が落ち着いてから
    -- event = { "BufReadPre", "BufNewFile" }, -- ファイルを開いたとき
    -- cmd = { "PluginCommand" },       -- そのコマンドを打ったとき
    -- ft = { "markdown", "python" },   -- その種類のファイルを開いたとき
    -- lazy = false,                    -- 遅延せず起動時に必ず読む

    -- ---------- 依存プラグイン ----------
    -- これより先に読み込まれる
    -- dependencies = { "nvim-lua/plenary.nvim" },

    -- ---------- 設定 ----------
    -- opts を書くと require("plugin").setup(opts) が自動で呼ばれる。
    -- 基本はこちらを使うのが楽。
    opts = {},

    -- setup() 以外の処理も必要なとき（ユーザーコマンド登録など）は
    -- opts の代わりに config を使う
    -- config = function()
    --   require("plugin").setup()
    --   vim.api.nvim_create_user_command("Foo", require("plugin").foo, {})
    -- end,

    -- ---------- キーマップ ----------
    -- ここに書いたキーを押した瞬間にプラグインが読み込まれる
    -- keys = {
    --   { "<leader>x", "<cmd>PluginCommand<cr>", desc = "説明文" },
    --   { "<leader>y", function() require("plugin").bar() end, mode = { "n", "x" }, desc = "説明文" },
    -- },

    -- ---------- その他 ----------
    -- build = "make",        -- インストール/更新時に走らせるコマンド
    -- version = "^1.0.0",    -- バージョン固定（省略時は最新コミット）
    -- enabled = false,       -- 一時的に無効化したいとき
  },
}
