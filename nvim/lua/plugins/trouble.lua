return {
  "folke/trouble.nvim",
  dependencies = { 'echasnovski/mini.icons' },
  cmd = "Trouble",
  opts = {
    -- 必要に応じてここにカスタム設定を記述します。
    -- 空のテーブル {} のままでも、非常に美しいデフォルト設定が適用されます。
    modes = {
      -- プレビューウィンドウをデフォルトで有効化したい場合などのカスタマイズ
      preview = {
        position = "right",
        size = 0.4,
      },
    },
  },
  keys = {
    -- プロジェクト全体の診断（エラー・警告）をトグル
    {
      "<leader>xx",
      "<cmd>Trouble diagnostics toggle win={size=0.2}<cr>",
      desc = "Diagnostics (Trouble)",
    },
    -- 現在のバッファ（ファイル）のみの診断をトグル
    {
      "<leader>xX",
      "<cmd>Trouble diagnostics toggle filter.buf=0 win={size=0.2}<cr>",
      desc = "Buffer Diagnostics (Trouble)",
    },
    -- LSPのシンボル（関数や変数の構造一覧）を右側にトグル
    {
      "<leader>cs",
      "<cmd>Trouble symbols toggle focus=false win={position=right, size=0.3}<cr>",
      desc = "Symbols (Trouble)",
    },
    -- LSPの定義や参照元（References）をトグル
    {
      "<leader>cl",
      "<cmd>Trouble lsp toggle focus=false win={position=bottom, size=0.3}<cr>",
      desc = "LSP Definitions / References (Trouble)",
    },
    -- クイックフィックスリストの表示
    {
      "<leader>xq",
      "<cmd>Trouble qflist toggle win={size=0.2}<cr>",
      desc = "Quickfix List (Trouble)",
    },
    -- ロケーションリストの表示
    {
      "<leader>xl",
      "<cmd>Trouble loclist toggle win={size=0.2}<cr>",
      desc = "Location List (Trouble)",
    },
  },
}
