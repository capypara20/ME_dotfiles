return {
  -- 「ヤンクした文字で対象を置き換える」オペレーター。
  -- 例: 単語をyankして、_iw で別の単語をそのyank内容に置換できる。
  -- 本体だけでは動かず、土台のvim-operator-userが必須。
  {
    "kana/vim-operator-replace",
    dependencies = { "kana/vim-operator-user" },
    keys = {
      -- ノーマル: _ + 範囲指定（例 _iw で単語を置換）
      { "_", "<Plug>(operator-replace)", mode = "n", desc = "Replace with yanked" },
      -- ビジュアル: 選択範囲を置換
      { "_", "<Plug>(operator-replace)", mode = "x", desc = "Replace with yanked" },
    },
  },
}
