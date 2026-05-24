return {
  "olimorris/codecompanion.nvim",

  -- ================================================================
  -- 依存プラグイン
  -- ================================================================
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },

  -- ================================================================
  -- 遅延読み込み: 以下のコマンド/キーを使った時にだけロード
  -- ================================================================
  cmd = {
    "CodeCompanion",
    "CodeCompanionChat",
    "CodeCompanionActions",
    "CodeCompanionCmd",
  },

  -- ================================================================
  -- キーマップ定義
  -- ================================================================
  keys = {
    -- トップレベル: 頻出操作
    {
      "<leader>aa",
      "<cmd>CodeCompanionActions<cr>",
      mode = { "n", "v" },
      desc = "AI: Actions パレットを開く",
    },
    {
      "<leader>ac",
      "<cmd>CodeCompanionChat<cr>",
      mode = { "n", "v" },
      desc = "AI: 新規 Chat を開始",
    },
    {
      "<leader>at",
      "<cmd>CodeCompanionChat Toggle<cr>",
      mode = { "n", "v" },
      desc = "AI: Chat 表示/非表示を切り替え (Toggle)",
    },
    {
      "<leader>ai",
      ":CodeCompanion ",
      mode = { "n", "v" },
      desc = "AI: Inline 編集（プロンプト入力）",
      silent = false, -- コマンドラインを表示してプロンプト入力させる
    },
    {
      "<leader>ax",
      "<cmd>CodeCompanionChat Add<cr>",
      mode = "v",
      desc = "AI: 選択範囲を Chat に追加",
    },
    {
      "<leader>am",
      "<cmd>CodeCompanionCmd<cr>",
      mode = "n",
      desc = "AI: コマンドライン生成 (Cmd)",
    },

    -- クイックプロンプト: <leader>aq 配下
    {
      "<leader>aqe",
      "<cmd>CodeCompanion /explain<cr>",
      mode = { "n", "v" },
      desc = "AI Quick: 選択コードを explain (説明)",
    },
    {
      "<leader>aqf",
      "<cmd>CodeCompanion /fix<cr>",
      mode = { "n", "v" },
      desc = "AI Quick: 選択コードを fix (修正)",
    },
    {
      "<leader>aqt",
      "<cmd>CodeCompanion /tests<cr>",
      mode = { "n", "v" },
      desc = "AI Quick: tests (ユニットテスト生成)",
    },
    {
      "<leader>aql",
      "<cmd>CodeCompanion /lsp<cr>",
      mode = { "n", "v" },
      desc = "AI Quick: LSP診断を解説",
    },
    {
      "<leader>aqc",
      "<cmd>CodeCompanion /commit<cr>",
      mode = "n",
      desc = "AI Quick: commit メッセージ生成",
    },

    -- ユーティリティ
    {
      "<leader>al",
      "<cmd>CodeCompanionLog<cr>",
      mode = "n",
      desc = "AI: Log を表示",
    },
    {
      "<leader>ar",
      "<cmd>CodeCompanionChat RefreshCache<cr>",
      mode = "n",
      desc = "AI: Chat キャッシュを更新",
    },
  },

  -- ================================================================
  -- プラグイン設定
  -- ================================================================
  opts = {
    -- アダプタ定義
    adapters = {
      http = {
        ollama_main = function()
          return require("codecompanion.adapters").extend("ollama", {
            name = "ollama_main",
            schema = {
              model = { default = "qwen2.5-coder:32b" },
              num_ctx = { default = 32768 },    -- コンテキスト長
              num_predict = { default = -1 },   -- 生成トークン上限
              temperature = { default = 0.2 },  -- 温度
              top_p = { default = 0.9 },        -- 確率カットオフ
              keep_alive = { default = "30m" }, -- モデルをVRAMに保持する時間
            },
          })
        end,

        -- アダプタ表示制御
        opts = {
          -- プリセットアダプタ(anthropic等)を非表示にしてUI簡素化
          show_presets = false,
        },
      },
    },

    -- ----------------------------------------------------------
    -- インタラクション別アダプタ割当
    -- ----------------------------------------------------------
    interactions = {
      chat   = { adapter = "ollama_main" },
      inline = { adapter = "ollama_main" },
      cmd    = { adapter = "ollama_main" },
    },

    -- ----------------------------------------------------------
    -- 表示・UI設定
    -- ----------------------------------------------------------
    display = {
      chat = {
        -- チャットバッファ上部にモデル設定を表示
        show_settings = true,
        -- チャットウィンドウ幅 (画面比0.0〜1.0)
        window = {
          width = 0.5,
        },
      },
      -- 差分表示プロバイダ (デフォルトのまま)
      diff = {
        enabled = true,
        provider = "default",
      },
    },

    -- ----------------------------------------------------------
    -- プラグイン全般設定
    -- ----------------------------------------------------------
    opts = {
      -- ログレベル: 初期はINFO、トラブル時はDEBUG/TRACEへ変更
      log_level = "INFO",
      -- 応答言語の指定 (システムプロンプトに追加される)
      language = "Japanese",
    },
  },

  config = function(_, opts)
    require("codecompanion").setup(opts)

    -- チャットバッファが開かれた時に専用キーマップを設定する
    vim.api.nvim_create_autocmd("FileType", {
      group    = vim.api.nvim_create_augroup("CodeCompanionChatKeys", { clear = true }),
      pattern  = "codecompanion",
      callback = function(ev)
        -- チャットバッファ内での <leader>at でウィンドウを閉じる
        vim.keymap.set("n", "<leader>at",
          "<cmd>CodeCompanionChat Toggle<cr>",
          {
            buffer = ev.buf, -- このチャットバッファにのみ適用
            silent = true,
            desc   = "AI: Chat Toggle（チャットバッファ内から閉じる）",
          }
        )
      end,
    })
  end,
}
