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
    -- 階層やグループにDescriptionを設定
    spec = {
      { "<leader>c", group = "Code (LSP操作)", icon = " " },
      { "<leader>f", group = "Find/File", icon = "󰈞 " },
      { "<leader>g", group = "Git", icon = " " },
      { "<leader>l", group = "LSP (管理)", icon = " " },
      { "<leader>x", group = "Diagnostics", icon = " " },
      { "<leader>m", group = "Markdown", icon = " " },
      { "<leader>b", group = "Buffer" },
      -- AI を追加するならここに
      -- { "<leader>a", group = "AI (CodeCompanion)", icon = " " },
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
