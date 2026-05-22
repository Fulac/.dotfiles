return {
  -----------------------------------------------------------------------------
  -- mini.icons（アイコンシステム ＆ 他プラグイン向けの互換レイヤー）
  -----------------------------------------------------------------------------
  {
    "echasnovski/mini.icons",
    version = false,
    lazy = false, -- 他のプラグインが起動する前に確実に読み込ませる
    config = function()
      require("mini.icons").setup()

      -- 従来の nvim-web-devicons を要求するプラグイン向けに互換レイヤー（モック）を張る
      require("mini.icons").mock_nvim_web_devicons()
    end,
  },

  -----------------------------------------------------------------------------
  -- mini.pairs（カッコの自動補完）
  -----------------------------------------------------------------------------
  {
    "echasnovski/mini.pairs",
    version = false,
    lazy = false,
    opts = {
      modes = { insert = true, command = false, terminal = false },
      mappings = {},
    },
  },

  -----------------------------------------------------------------------------
  -- mini.comment
  -----------------------------------------------------------------------------
  {
    "echasnovski/mini.comment",
    version = false,
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("mini.comment").setup()
    end,
  },

  -----------------------------------------------------------------------------
  -- mini.indentscope
  -----------------------------------------------------------------------------
  {
    "echasnovski/mini.indentscope",
    version = false,
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("mini.indentscope").setup({
        symbol = "│", -- 表示する縦線のスタイル
        options = { try_as_border = true },
      })
    end,
  },
}
