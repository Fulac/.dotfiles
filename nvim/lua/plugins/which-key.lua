return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    -- 表示のプリセット ("classic", "modern", "helix")
    preset = "modern",
    -- ポップアップが表示されるまでの遅延（ms）
    delay = 500,
    -- アイコン表示を無効化
    icons = {
      mappings = false, -- desc から推測される自動アイコンを抑止
      rules = false,    -- 自動アイコンルール (filetype 連想など) も抑止
      keys = {},        -- 特殊キー (<Tab>, <CR> 等) のアイコンも全て無効化
    },
    -- 階層やグループにDescriptionを設定
    spec = {
      { "<leader>c", group = "Code (LSP操作)" },
      { "<leader>f", group = "Find/File" },
      { "<leader>g", group = "Git" },
      { "<leader>l", group = "LSP (管理)" },
      { "<leader>x", group = "Diagnostics" },
      { "<leader>m", group = "Markdown" },
      { "<leader>b", group = "Buffer" },
      -- AI を追加するならここに
      -- { "<leader>a", group = "AI (CodeCompanion)" },
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
