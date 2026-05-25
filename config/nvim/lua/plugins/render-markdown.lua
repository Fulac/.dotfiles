return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "echasnovski/mini.icons",
  },
  ft = { "markdown" }, -- Markdown ファイルを開いた時だけロード
  keys = {
    {
      "<leader>mr",
      "<cmd>RenderMarkdown toggle<cr>",
      ft = "markdown",
      desc = "Toggle Render-Markdown (inline)",
    },
  },
  opts = {
    -- ----------------------------------------------------------
    -- 表示モードの設定
    -- ----------------------------------------------------------
    -- 起動時はレンダリング OFF (ソースコード表示)
    -- <leader>mr でトグルして ON にする
    enabled = false,

    -- ノーマルモード・コマンドラインモードでのみレンダリング
    -- インサートモードは生テキストが見えた方が編集しやすいため除外
    render_modes = { "n", "c" },

    -- アンチコンシール: カーソルが乗っている行は生の Markdown を表示
    -- これにより編集時に記号が邪魔にならない
    anti_conceal = {
      enabled = true,
      -- カーソル行の上下何行まで生テキストを表示するか
      above = 0,
      below = 0,
    },

    -- ----------------------------------------------------------
    -- 見出し (Heading)
    -- ----------------------------------------------------------
    heading = {
      -- 見出しレベル別アイコン (H1〜H6)
      icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
      -- 見出し行の左端から画面端まで背景色を伸ばす
      width = "full",
      -- 見出しレベルごとの左パディング (インデント感を出す)
      left_pad = 0,
      right_pad = 0,
      -- 見出しの上下に空行を追加してセパレーション
      above = "▄",
      below = "▀",
      -- bg = "NONE" に統一
      backgrounds = {
        "NONE",
        "NONE",
        "NONE",
        "NONE",
        "NONE",
        "NONE",
      },
      -- 見出しレベルごとの前景色 (kanagawa wave のカラーパレット準拠)
      foregrounds = {
        "RenderMarkdownH1", -- H1: 赤系
        "RenderMarkdownH2", -- H2: オレンジ系
        "RenderMarkdownH3", -- H3: 黄色系
        "RenderMarkdownH4", -- H4: 緑系
        "RenderMarkdownH5", -- H5: 青系
        "RenderMarkdownH6", -- H6: 紫系
      },
    },

    -- ----------------------------------------------------------
    -- コードブロック (Code Block)
    -- ----------------------------------------------------------
    code = {
      -- "full": 言語ラベル行 + コード本体に背景色を適用
      -- "normal": コード本体のみ
      -- "language": 言語ラベルのみ
      style = "full",
      -- コードブロックの枠線スタイル ("thin" | "thick" | "none")
      border = "thin",
      -- 左端のパディング (見やすさのため)
      left_pad = 2,
      right_pad = 2,
      -- 言語アイコンを mini.icons から取得して表示
      language_icon = true,
      -- 言語名をアイコンの右に表示
      language_name = true,
      -- 通常ハイライトに任せる
      highlight = "RenderMarkdownCode",
      highlight_language = "RenderMarkdownCodeLanguage",
      -- inline コードの強調
      highlight_inline = "RenderMarkdownCodeInline",
    },

    -- ----------------------------------------------------------
    -- テーブル (Pipe Table)
    -- ----------------------------------------------------------
    pipe_table = {
      -- "full": ヘッダ・区切り・行の全てを整形
      -- "normal": 罫線なし
      style = "full",
      -- 罫線プリセット ("none" | "round" | "double" | "heavy")
      preset = "round",
      -- セルの左右パディング
      padding = 1,
      -- アライメントインジケータ (右揃え・中央揃えの表示)
      alignment_indicator = "━",
      -- ヘッダ行のハイライト
      head = "RenderMarkdownTableHead",
      -- データ行のハイライト
      row = "RenderMarkdownTableRow",
    },

    -- ----------------------------------------------------------
    -- チェックボックス (Checkbox)
    -- ----------------------------------------------------------
    checkbox = {
      unchecked = {
        icon = "󰄱 ", -- 空のチェックボックス
        highlight = "RenderMarkdownUnchecked",
      },
      checked = {
        icon = "󰱒 ", -- チェック済み
        highlight = "RenderMarkdownChecked",
      },
      custom = {
        -- 独自チェックボックスの追加定義
        -- Obsidian 互換の状態表示
        todo = {
          raw = "[-]",
          rendered = "󰥔 ", -- 進行中
          highlight = "RenderMarkdownTodo",
        },
        important = {
          raw = "[~]",
          rendered = "󰓎 ", -- 重要
          highlight = "RenderMarkdownWarn",
        },
      },
    },

    -- ----------------------------------------------------------
    -- Callout / Blockquote
    -- ----------------------------------------------------------
    -- Obsidian 互換の callout 記法に対応
    -- > [!NOTE], > [!TIP], > [!WARNING], > [!CAUTION], > [!IMPORTANT]
    callout = {
      note = {
        raw = "[!NOTE]",
        rendered = "󰋽 Note",
        highlight = "RenderMarkdownInfo",
      },
      tip = {
        raw = "[!TIP]",
        rendered = "󰌶 Tip",
        highlight = "RenderMarkdownSuccess",
      },
      important = {
        raw = "[!IMPORTANT]",
        rendered = "󰅾 Important",
        highlight = "RenderMarkdownHint",
      },
      warning = {
        raw = "[!WARNING]",
        rendered = "󰀪 Warning",
        highlight = "RenderMarkdownWarn",
      },
      caution = {
        raw = "[!CAUTION]",
        rendered = "󰳦 Caution",
        highlight = "RenderMarkdownError",
      },
      todo = {
        raw = "[!TODO]",
        rendered = "󰥔 Todo",
        highlight = "RenderMarkdownTodo",
      },
    },

    -- ----------------------------------------------------------
    -- 箇条書きリスト (Bullet List)
    -- ----------------------------------------------------------
    bullet = {
      -- ネストレベル別のアイコン
      icons = { "●", "○", "◆", "◇" },
      -- アイコンの左パディング
      left_pad = 0,
      right_pad = 0,
      highlight = "RenderMarkdownBullet",
    },

    -- ----------------------------------------------------------
    -- リンク
    -- ----------------------------------------------------------
    link = {
      -- 通常リンクのアイコン
      image = "󰥶 ", -- 画像リンク
      email = "󰀓 ", -- メールリンク
      hyperlink = "󰌹 ", -- URL リンク
      -- ファイルリンクは mini.icons から自動取得
      custom = {
        -- .lua ファイルへのリンク
        lua = {
          pattern = "%.lua$",
          icon = " ",
          highlight = "RenderMarkdownLink",
        },
        -- .py ファイルへのリンク
        python = {
          pattern = "%.py$",
          icon = " ",
          highlight = "RenderMarkdownLink",
        },
        -- .yaml / .yml ファイルへのリンク (Ansible playbook)
        yaml = {
          pattern = "%.ya?ml$",
          icon = " ",
          highlight = "RenderMarkdownLink",
        },
      },
    },

    -- ----------------------------------------------------------
    -- 水平線 (Thematic Break)
    -- ----------------------------------------------------------
    dash = {
      icon = "─",
      -- 画面幅いっぱいに表示
      width = "full",
      highlight = "RenderMarkdownDash",
    },

    -- ----------------------------------------------------------
    -- 引用 (Block Quote)
    -- ----------------------------------------------------------
    quote = {
      icon = "▋",
      highlight = "RenderMarkdownQuote",
    },

    -- ----------------------------------------------------------
    -- blink.cmp との補完連携
    -- ----------------------------------------------------------
    completions = {
      lsp = { enabled = true },
    },

    -- ----------------------------------------------------------
    -- パフォーマンス設定
    -- ----------------------------------------------------------
    -- デバウンス: スクロール・編集中にレンダリングを間引く (ms)
    -- 値が小さいほど即時レンダリングだが CPU 負荷増
    debounce = 100,

    -- 巨大ファイルのレンダリング無効化の閾値 (行数)
    max_file_size = 10.0, -- MB

    -- ----------------------------------------------------------
    -- ファイルタイプ注入 (injection)
    -- ----------------------------------------------------------
    -- gitcommit バッファでも Markdown 記法を有効化
    injections = {
      gitcommit = {
        enabled = true,
        query = [[
          ((message) @injection.content
           (#set! injection.combined)
           (#set! injection.language "markdown"))
        ]],
      },
    },
  },

  config = function(_, opts)
    require("render-markdown").setup(opts)

    -- ----------------------------------------------------------
    -- ハイライト上書き
    -- ----------------------------------------------------------

    -- 見出しレベル別カラー (kanagawa wave 準拠)
    vim.api.nvim_set_hl(0, "RenderMarkdownH1", { fg = "#c34043", bg = "NONE", bold = true })
    vim.api.nvim_set_hl(0, "RenderMarkdownH2", { fg = "#ffa066", bg = "NONE", bold = true })
    vim.api.nvim_set_hl(0, "RenderMarkdownH3", { fg = "#c0a36e", bg = "NONE", bold = true })
    vim.api.nvim_set_hl(0, "RenderMarkdownH4", { fg = "#76946a", bg = "NONE", bold = true })
    vim.api.nvim_set_hl(0, "RenderMarkdownH5", { fg = "#7e9cd8", bg = "NONE", bold = true })
    vim.api.nvim_set_hl(0, "RenderMarkdownH6", { fg = "#957fb8", bg = "NONE", bold = true })

    -- 見出しの区切り線 (▄ / ▀)
    vim.api.nvim_set_hl(0, "RenderMarkdownH1Bg", { fg = "#c34043", bg = "NONE" })
    vim.api.nvim_set_hl(0, "RenderMarkdownH2Bg", { fg = "#ffa066", bg = "NONE" })
    vim.api.nvim_set_hl(0, "RenderMarkdownH3Bg", { fg = "#c0a36e", bg = "NONE" })
    vim.api.nvim_set_hl(0, "RenderMarkdownH4Bg", { fg = "#76946a", bg = "NONE" })
    vim.api.nvim_set_hl(0, "RenderMarkdownH5Bg", { fg = "#7e9cd8", bg = "NONE" })
    vim.api.nvim_set_hl(0, "RenderMarkdownH6Bg", { fg = "#957fb8", bg = "NONE" })

    -- コードブロック背景 (わずかに明るくして識別)
    vim.api.nvim_set_hl(0, "RenderMarkdownCode", { bg = "NONE" })
    vim.api.nvim_set_hl(0, "RenderMarkdownCodeLanguage", { fg = "#727169", bg = "NONE", italic = true })
    vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", { fg = "#c8c093", bg = "NONE" })

    -- テーブル
    vim.api.nvim_set_hl(0, "RenderMarkdownTableHead", { fg = "#7e9cd8", bg = "NONE", bold = true })
    vim.api.nvim_set_hl(0, "RenderMarkdownTableRow", { fg = "#dcd7ba", bg = "NONE" })

    -- チェックボックス
    vim.api.nvim_set_hl(0, "RenderMarkdownChecked", { fg = "#76946a", bg = "NONE" })   -- 緑 (完了)
    vim.api.nvim_set_hl(0, "RenderMarkdownUnchecked", { fg = "#727169", bg = "NONE" }) -- グレー (未完)
    vim.api.nvim_set_hl(0, "RenderMarkdownTodo", { fg = "#e6c384", bg = "NONE" })      -- 黄 (進行中)

    -- Callout / Blockquote
    vim.api.nvim_set_hl(0, "RenderMarkdownInfo", { fg = "#7e9cd8", bg = "NONE" })    -- 青 (NOTE)
    vim.api.nvim_set_hl(0, "RenderMarkdownSuccess", { fg = "#76946a", bg = "NONE" }) -- 緑 (TIP)
    vim.api.nvim_set_hl(0, "RenderMarkdownHint", { fg = "#957fb8", bg = "NONE" })    -- 紫 (IMPORTANT)
    vim.api.nvim_set_hl(0, "RenderMarkdownWarn", { fg = "#e6c384", bg = "NONE" })    -- 黄 (WARNING)
    vim.api.nvim_set_hl(0, "RenderMarkdownError", { fg = "#c34043", bg = "NONE" })   -- 赤 (CAUTION)

    -- 箇条書き・水平線・引用
    vim.api.nvim_set_hl(0, "RenderMarkdownBullet", { fg = "#ffa066", bg = "NONE" })
    vim.api.nvim_set_hl(0, "RenderMarkdownDash", { fg = "#504945", bg = "NONE" })
    vim.api.nvim_set_hl(0, "RenderMarkdownQuote", { fg = "#727169", bg = "NONE", italic = true })

    -- リンク
    vim.api.nvim_set_hl(0, "RenderMarkdownLink", { fg = "#6a9589", bg = "NONE", underline = true })

    -- ----------------------------------------------------------
    -- ColorScheme 変更時にハイライトを再適用
    -- ----------------------------------------------------------
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("RenderMarkdownColors", { clear = true }),
      callback = function()
        vim.api.nvim_set_hl(0, "RenderMarkdownH1", { fg = "#c34043", bg = "NONE", bold = true })
        vim.api.nvim_set_hl(0, "RenderMarkdownH2", { fg = "#ffa066", bg = "NONE", bold = true })
        vim.api.nvim_set_hl(0, "RenderMarkdownH3", { fg = "#c0a36e", bg = "NONE", bold = true })
        vim.api.nvim_set_hl(0, "RenderMarkdownH4", { fg = "#76946a", bg = "NONE", bold = true })
        vim.api.nvim_set_hl(0, "RenderMarkdownH5", { fg = "#7e9cd8", bg = "NONE", bold = true })
        vim.api.nvim_set_hl(0, "RenderMarkdownH6", { fg = "#957fb8", bg = "NONE", bold = true })
        vim.api.nvim_set_hl(0, "RenderMarkdownCode", { bg = "NONE" })
        vim.api.nvim_set_hl(0, "RenderMarkdownCodeLanguage", { fg = "#727169", bg = "NONE", italic = true })
        vim.api.nvim_set_hl(0, "RenderMarkdownCodeInline", { fg = "#c8c093", bg = "NONE" })
        vim.api.nvim_set_hl(0, "RenderMarkdownTableHead", { fg = "#7e9cd8", bg = "NONE", bold = true })
        vim.api.nvim_set_hl(0, "RenderMarkdownTableRow", { fg = "#dcd7ba", bg = "NONE" })
        vim.api.nvim_set_hl(0, "RenderMarkdownBullet", { fg = "#ffa066", bg = "NONE" })
        vim.api.nvim_set_hl(0, "RenderMarkdownDash", { fg = "#504945", bg = "NONE" })
        vim.api.nvim_set_hl(0, "RenderMarkdownLink", { fg = "#6a9589", bg = "NONE", underline = true })
      end,
    })
  end,
}
