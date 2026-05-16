return {
  "folke/snacks.nvim",
  priority = 1000, -- 起動時に最優先で初期化
  lazy = false,
  opts = {
    -----------------------------------------------------------------------------
    -- Snacks.Featuresの有効化
    -----------------------------------------------------------------------------
    picker = {
      enabled = true,
      -- 必要に応じて好みのレイアウト（"default" | "vertical" | "vscode" | "ivy" など）
      layout = {
        preset = "default",
      },
    },
    bigfile  = { enabled = true },  -- 巨大なファイル（ログ等）を開いた時、自動でTreesitter等を切る
    notifier = { enabled = true },  -- 通知UI
    words    = { enabled = true },  -- カーソル下の単語と同じ単語を自動ハイライト

    -----------------------------------------------------------------------------
    -- E1512 (extends および lastline の文字幅エラー) 回避設定
    -----------------------------------------------------------------------------
    styles = {
      minimal = {
        wo = {
          listchars = "tab:  ,extends:>,precedes:<,nbsp:+",
          fillchars = "eob: ,lastline:@",
        },
      },
    },
  },

  -----------------------------------------------------------------------------
  -- キーマッピング
  -----------------------------------------------------------------------------
  keys = {
    -- プロジェクト内のファイル検索
    { "<leader><space>", function() Snacks.picker.files() end, desc = "Find Files (Project)" },
    { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
    
    -- プロジェクト内を文字列検索
    { "<leader>fg", function() Snacks.picker.grep() end, desc = "Grep Search" },
    
    -- 開いているバッファ一覧
    { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
    
    -- 最近開いたファイル履歴
    { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent Files" },
    
    -- Neovimのヘルプタグ検索
    { "<leader>fh", function() Snacks.picker.help() end, desc = "Help Pages" },
    
    -- 現在のバッファ内をファジー検索
    { "<leader>f/", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
    
    -- Gitのコミット履歴、ステータスの検索
    { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
    { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
  },
}
