-- カラースキーム: catppuccin
--
-- 【色を見比べる方法】
--   ノーマルモードで  <Space>u C  → 一覧が出て、カーソルを動かすと即プレビュー
--   Enter で確定（ただし再起動すると戻る）
--
-- 【気に入った色を固定する方法】
--   下の colorscheme = "..." を書き換えて nvim を再起動するだけ。
--     "catppuccin-latte"      … 白背景（ライト）
--     "catppuccin-frappe"     … 一番明るいダーク
--     "catppuccin-macchiato"  … 中くらいのダーク
--     "catppuccin-mocha"      … 一番濃いダーク（catppuccin の定番）
--
-- ※ catppuccin 本体のスペックは LazyVim が既に定義済み
--   (lazyvim/plugins/colorscheme.lua に integrations が30個以上書かれている)
--   ここに書いた opts はそれに「合体」される。上書きではないので消えない。

return {
  -- ① 実際に使う色を指定する（ここが本命）
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-macchiato",
    },
  },

  -- ② catppuccin 本体の好みの設定（不要なら丸ごと消してもOK）
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      -- 背景を透過してターミナルの壁紙を透かす
      -- true にすると一部の枠線が見づらくなることがある
      transparent_background = false,
      term_colors = true,
      dim_inactive = { enabled = true },

      -- コメントを斜体にしない（Nerd Font によっては斜体が崩れるため）
      no_italic = false,

      styles = {
        comments = { "italic" },
        keywords = { "bold" },
      },
    },
  },
}
