return {
  -- LSPのUIを強化（定義プレビュー、綺麗なホバー、アウトライン等）
  {
    "nvimdev/lspsaga.nvim",
    event = "LspAttach",
    opts = {},
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-mini/mini.icons",
    },
    keys = {
      -- ホバー情報（型・説明）を綺麗な枠で表示
      { "K", "<cmd>Lspsaga hover_doc<cr>", desc = "Lspsaga Hover" },
      -- カーソル位置のエラー/警告を吹き出しで表示
      { "<leader>cd", "<cmd>Lspsaga show_line_diagnostics<cr>", desc = "Line Diagnostics" },
      -- 定義をポップアップでチラ見（ジャンプせず確認）
      { "gp", "<cmd>Lspsaga peek_definition<cr>", desc = "Peek Definition" },
      -- コードの構造ツリーをサイドに表示
      { "<leader>o", "<cmd>Lspsaga outline<cr>", desc = "Outline" },
      -- リネーム（プレビュー付き）
      { "<leader>cr", "<cmd>Lspsaga rename<cr>", desc = "Lspsaga Rename" },
    },
  },
}
