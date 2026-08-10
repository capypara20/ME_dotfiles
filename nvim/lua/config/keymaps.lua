local map = vim.keymap.set

map("i", "jj", "<ESC>", { silent = true })

-- :terminal など Snacks 以外のターミナルバッファでも Esc2回で Normal モードに戻す
local term_esc_timer
map("t", "<esc>", function()
  term_esc_timer = term_esc_timer or (vim.uv or vim.loop).new_timer()
  if term_esc_timer:is_active() then
    term_esc_timer:stop()
    vim.cmd("stopinsert")
  else
    term_esc_timer:start(400, 0, function() end)
    return "<esc>"
  end
end, { expr = true, desc = "Double escape to normal mode (terminal)" })
