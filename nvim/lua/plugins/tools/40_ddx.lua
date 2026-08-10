return {
  -- Deno製プラグインの土台。ddx等を動かすのに必須。
  {
    "vim-denops/denops.vim",
    lazy = false,
    init = function()
      -- deno の置き場所は入れ方で変わる:
      --   scoop      … ~\scoop\shims\deno.exe
      --   公式スクリプト … ~/.deno/bin/deno
      --   Linux のパッケージ … /usr/bin/deno など
      -- そのため決め打ちにせず、まず PATH から探す。
      if vim.fn.executable("deno") == 1 then
        vim.g["denops#deno"] = "deno"
      else
        -- PATH に無いときだけ、公式インストーラの既定の場所を見る
        local fallback = vim.fn.expand("~/.deno/bin/deno")
        if vim.fn.executable(fallback) == 1 then
          vim.g["denops#deno"] = fallback
        end
      end
    end,
  },
  -- ファイル/バッファ等をあいまい検索するUIフレームワーク
  {
    "Shougo/ddx.vim",
    dependencies = { "vim-denops/denops.vim" },
    lazy = false,
  },
}
