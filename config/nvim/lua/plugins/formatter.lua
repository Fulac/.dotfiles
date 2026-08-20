return {
  "stevearc/conform.nvim",
  -- ファイル書き込み直前に遅延ロード
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end,
      mode = { "n", "v" }, -- ノーマル・ビジュアル両モードで実行可能
      desc = "Format Buffer (Conform)",
    },
  },
  opts = {
    -- 言語ごとのフォーマッター割り当て
    formatters_by_ft = {
      python = { "ruff_format" }, -- LSPのruffと連携して超高速整形
      yaml = { "prettier" },
      json = { "prettier" },
      markdown = { "prettier" },
      c = { "clang-format" },
      cpp = { "clang-format" },
    },
    -- 以下に、フォーマッタの挙動変更設定を記載
    formatters = {
      ["clang-format"] = {
        prepend_args = {
          -- 直接YAML形式のスタイル設定を引数として流し込む
          -- デフォルトと同じ設定（タブ幅などを変えたければ以下を編集する）
          "--style={BasedOnStyle: LLVM, IndentWidth: 4, UseTab: Never}",
        },
      },
    },
    format_on_save = {
      timeout_ms = 500,
      lsp_format = "never",
    },
  },
}
