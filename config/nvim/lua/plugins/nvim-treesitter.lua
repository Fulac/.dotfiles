return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  -- event 指定で、Neovimが完全に起動してパスが通った後に読み込ませる
  event = { "BufReadPost", "BufNewFile" },
  main = "nvim-treesitter.configs",
  config = function()
    -- 言語パーサーのインストール
    require("nvim-treesitter").install({
      -- 基本言語 & 共通フォーマット
      "c", "cpp", "rust", "lua", "vim", "vimdoc", "python", "javascript", "html", "json", "yaml", "query",
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
    })

    -- シンタックスハイライトの自動有効化
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("TreesitterHighlight", { clear = true }),
      callback = function()
        pcall(vim.treesitter.start)
      end,
    })

    -- インデントの自動有効化
    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("TreesitterIndent", { clear = true }),
      callback = function()
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
