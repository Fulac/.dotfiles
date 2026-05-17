return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  build = ":TSUpdate",
  -- event 指定で、Neovimが完全に起動してパスが通った後に読み込ませる
  event = { "BufReadPost", "BufNewFile" },
  main = "nvim-treesitter.configs",
  opts = {
    ensure_installed = {
      -- 基本言語 & 共通フォーマット
      "c", "cpp", "lua", "vim", "vimdoc", "python", "javascript", "html", "json", "yaml", "query",
      -- ドキュメント & テキストノート
      "markdown",
      "markdown_inline",
      -- シェルスクリプト & システム管理
      "bash",
      "regex",
      -- インフラ・コンテナ・モダン設定ファイル
      "dockerfile",
      "toml",
      -- Git・バージョン管理・差分確認
      "diff",
      "gitcommit",
      "gitignore",
    },
    -- 非同期で安全にインストールを回すため
    sync_install = false,

    highlight = { enable = true },
    indent = { enable = true },
  },
}
