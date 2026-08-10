return {
  -- ============ oil本体 ============
  {
    "stevearc/oil.nvim",
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
      -- デフォルトでoilをファイラーに
      default_file_explorer = true,
      -- 表示するカラム（ファイル名は常に一番右に固定）
      columns = {
        "icon",
        { "mtime", format = "%Y-%m-%d %H:%M:%S" },
        "size",
      },
      -- 削除はごみ箱へ
      delete_to_trash = true,
      -- 簡単な操作（リネーム等）は確認ポップアップなし
      skip_confirm_for_simple_edits = true,
      -- 他のアプリがファイルを増減させたら自動で表示を更新
      watch_for_changes = true,
      view_options = {
        -- 隠しファイルも全部表示
        show_hidden = true,
      },
      win_options = {
        -- git-status表示用に左端の署名欄を2列確保（oil-git-status必須設定）
        signcolumn = "yes:2",
      },
    },
    dependencies = { { "nvim-mini/mini.icons", opts = {} } },
    lazy = false,
    keys = {
      { "-", "<cmd>Oil<cr>" },
    },
  },

  -- ============ 拡張: gitの状態を左端に表示 ============
  {
    "refractalize/oil-git-status.nvim",
    dependencies = { "stevearc/oil.nvim" },
    opts = {},
  },

  -- ============ 拡張: エラー/警告のあるファイルにマーク表示 ============
  {
    "JezerM/oil-lsp-diagnostics.nvim",
    dependencies = { "stevearc/oil.nvim" },
    opts = {},
  },
}
