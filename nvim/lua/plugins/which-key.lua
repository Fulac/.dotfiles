return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    -- 表示のプリセット ("classic", "modern", "helix")
    preset = "modern",
    -- ポップアップが表示されるまでの遅延（ms）
    delay = 500,
    -- アイコンを表示するかどうか（mini.icons や nvim-web-devicons と連携）
    icons = {
      mappings = true,
    },
    -- 階層やグループに名前（ラベル）を付けるための設定（v3の新しい仕様）
    spec = {
      { "<leader>f", group = "File/Find", icon = "󰈞 " },
      { "<leader>g", group = "Git", icon = " " },
      { "<leader>b", group = "Buffer" },
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
}
