return {
  -- Deno製プラグインの土台。ddx等を動かすのに必須。
  -- ※ Deno のインストールが前提（deno のパスは環境に合わせて要調整）
  {
    "vim-denops/denops.vim",
    lazy = false,
    init = function()
      vim.g["denops#deno"] = vim.fn.expand("~/.deno/bin/deno")
    end,
  },
  -- ファイル/バッファ等をあいまい検索するUIフレームワーク
  {
    "Shougo/ddx.vim",
    dependencies = { "vim-denops/denops.vim" },
    lazy = false,
  },
}
