return {
  -- Markdownをブラウザでライブプレビュー: :PeekOpen / :PeekClose
  -- ※ Deno が必要（build時に deno task を実行）
  {
    "toppair/peek.nvim",
    event = "VeryLazy",
    build = "deno task --quiet build:fast",
    config = function()
      require("peek").setup()
      vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
      vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
    end,
  },
}
