return {
  -- 囲み文字操作: cs"' で "..." を '...' に変更、ysiw( で単語を括弧で囲む等
  {
    "kylechui/nvim-surround",
    version = "^4.0.0",
    event = "VeryLazy",
    config = true,
  },

  -- 検索結果カウント表示: /foo で検索すると「3/12」のように件数を表示
  {
    "kevinhwang91/nvim-hlslens",
    config = true,
  },

  -- 今いるコードブロックをインデント線で色付け
  {
    "shellRaining/hlchunk.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      chunk = {
        style = "#806d9c",
        priority = 10,
        use_treesitter = false,
      },
    },
  },
}
