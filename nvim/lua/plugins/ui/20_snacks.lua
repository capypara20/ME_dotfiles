return {
  "folke/snacks.nvim",
  opts = {
    styles = {
      terminal = {
        keys = {
          term_normal = {
            "<esc>",
            function(self)
              self.esc_timer = self.esc_timer or (vim.uv or vim.loop).new_timer()
              if self.esc_timer:is_active() then
                self.esc_timer:stop()
                vim.cmd("stopinsert")
              else
                -- Escだけなら通常プロセスへそのまま送る。400ms以内にもう一度押すとNormalモードへ戻る
                self.esc_timer:start(400, 0, function() end)
                return "<esc>"
              end
            end,
            mode = "t",
            expr = true,
            desc = "Double escape to normal mode",
          },
        },
      },
    },
  },
}
