return {
  "rebelot/kanagawa.nvim",
  lazy = false,    -- 起動時に即座に読み込むため、遅延ロードは無効
  priority = 1000, -- 他のUIプラグイン（lualine等）よりも先に読み込ませる
  config = function()
    -- Kanagawaのオプション設定
    require("kanagawa").setup({
      compile = true,   -- 変更がない限り設定をコンパイルして起動を高速化
      undercurl = true, -- エラー等の下波線を有効化
      commentStyle = { italic = true },
      keywordStyle = { italic = true, bold = true },
      statementStyle = { bold = true },
      typeStyle = {},
      transparent = true,    -- タイリングWMやターミナル側で背景を透過させている場合は true に変更
      dimInactive = false,   -- 非アクティブなウィンドウを暗くする
      terminalColors = true, -- Neovim内のターミナルバッファにもカラーを適用

      -- テーマのバリエーション選択 ("wave" | "dragon" | "lotus")
      theme = "wave",
      background = { dark = "wave", light = "lotus" },

      -- カラー設定を独自設定へ上書き
      overrides = function(colors)
        local theme = colors.theme
        return {
          -- Pmenu (blink.cmpなどの補完UI) の視認性向上
          Pmenu        = { fg = theme.ui.fg, bg = "NONE" },
          PmenuSel     = { fg = "NONE", bg = theme.ui.bg_p2 },
          PmenuSbar    = { bg = theme.ui.bg_m1 },
          PmenuThumb   = { bg = theme.ui.bg_p2 },

          -- 共通フローティングウィンドウの背景 ＆ 枠線透過
          NormalFloat  = { bg = "NONE" },
          FloatBorder  = { fg = "#504945", bg = "NONE" },
          FloatTitle   = { fg = "#ffad5c", bg = "NONE", bold = true },

          -- エディタ基本UIの透過設定
          Normal       = { bg = "NONE" },
          NonText      = { bg = "NONE" },
          LineNr       = { fg = "#504945", bg = "NONE" },
          Folded       = { bg = "NONE" },
          EndOfBuffer  = { bg = "NONE" },
          CursorLine   = { bg = "NONE" },
          CursorLineNr = { fg = "#ffad5c", bg = "NONE" },
        }
      end,
    })

    -- カラースキームを適用
    vim.cmd("colorscheme kanagawa")
  end,
}
