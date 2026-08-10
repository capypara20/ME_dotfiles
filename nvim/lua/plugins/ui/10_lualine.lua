return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    -- パスを省略せず全部表示する (デフォルトは length=3 で "…" 省略される)
    opts.sections.lualine_c[4] = { LazyVim.lualine.pretty_path({ length = 0 }) }

    -- 時刻を 年月日 時:分:秒 まで表示する
    opts.sections.lualine_z = {
      function()
        return " " .. os.date("%Y-%m-%d %H:%M:%S")
      end,
    }

    return opts
  end,
}
