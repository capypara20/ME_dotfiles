return {
  -- バイナリエディター: :HexDump でバイナリ表示、:HexAssemble で戻す
  {
    "RaafatTurki/hex.nvim",
    config = function()
      require("hex").setup()
    end,
  },
}
