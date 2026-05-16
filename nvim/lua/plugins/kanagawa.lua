return {
  "rebelot/kanagawa.nvim",
  lazy = false,    -- 起動時に即座に読み込むため、遅延ロードは無効
  priority = 1000, -- 他のUIプラグイン（lualine等）よりも先に読み込ませる
  config = function()
    -- Kanagawaのオプション設定
    require("kanagawa").setup({
      compile = true,            -- 変更がない限り設定をコンパイルして起動を高速化
      undercurl = true,          -- エラー等の下波線を有効化
      commentStyle = { italic = true },
      keywordStyle = { italic = true, bold = true },
      statementStyle = { bold = true },
      typeStyle = {},
      transparent = true,        -- タイリングWMやターミナル側で背景を透過させている場合は true に変更
      dimInactive = false,       -- 非アクティブなウィンドウを暗くする
      terminalColors = true,     -- Neovim内のターミナルバッファにもカラーを適用

      -- テーマのバリエーション選択 ("wave" | "dragon" | "lotus")
      theme = "wave",            -- デフォルトは伝統的な和色の "wave"
      
      background = {             -- vim.o.background に応じた自動切り替え
        dark = "wave",           -- より深い黒が好みなら "dragon" もおすすめ
        light = "lotus"          -- 明るい背景用
      },

      -- 各種プラグインとのハイライトの調和設定
      overrides = function(colors)
        local theme = colors.theme
        return {
          -- ==========================================================================
          -- Snacks.pickerの色設定
          -- ==========================================================================
          SnacksPickerNormal        = { bg = "NONE" },
          SnacksPickerBorder        = { fg = theme.ui.bg_m1, bg = "NONE" },
          SnacksPickerInputNormal   = { bg = "NONE" },
          SnacksPickerInputBorder   = { fg = theme.ui.bg_m1, bg = "NONE" },
          SnacksPickerPreviewNormal = { bg = "NONE" },
          SnacksPickerPreviewBorder = { fg = theme.ui.bg_m1, bg = "NONE" },

          -- Pmenu (blink.cmpなどの補完ポップアップ) の視認性向上
          Pmenu = { fg = theme.ui.fg, bg = theme.ui.bg_p1 },
          PmenuSel = { fg = "NONE", bg = theme.ui.bg_p2 },
          PmenuSbar = { bg = theme.ui.bg_m1 },
          PmenuThumb = { bg = theme.ui.bg_p2 },
        }
      end,
    })

    -- カラースキームを適用 & 独自カラー設定の適用
    vim.cmd("colorscheme kanagawa")
    vim.api.nvim_set_hl(0, 'Normal', { bg = 'NONE', ctermbg = 'none' })
    vim.api.nvim_set_hl(0, 'NonText', { bg = 'NONE', ctermbg = 'none' })
    vim.api.nvim_set_hl(0, 'LineNr', { fg = '#504945', bg = 'NONE', ctermbg = 'none' })
    vim.api.nvim_set_hl(0, 'Folded', { bg = 'NONE', ctermbg = 'none' })
    vim.api.nvim_set_hl(0, 'EndOfBuffer', { bg = 'NONE', ctermbg = 'none' })
    vim.api.nvim_set_hl(0, 'CursorLine', { bg = 'none' })
    vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#ffad5c', bg = 'none' })
    vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'NONE', ctermbg = 'none' })
    vim.api.nvim_set_hl(0, 'FloatBorder', { fg = '#504945', bg = 'NONE', ctermbg = 'none' })
  end,
}
