return {
  "saghen/blink.cmp",
  opts = {
    -- Tab: 候補メニューが出ていれば次の候補へ移動 (即確定はしない)
    -- S-Tab: 前の候補へ移動
    -- Enter: 選んだ候補を確定 (preset = "enter" の設定を継承)
    -- 言語(LSP)に関係なく、path/buffer/snippets 由来の候補にも同じ挙動が適用される
    keymap = {
      preset = "enter",
      ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
      ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
    },
  },
}
