local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

-- ==========================================
-- リーダーキー設定
-- ==========================================
-- Ctrl+q をリーダーとして使用。
-- 使い方: Ctrl+q を押してから 1秒以内に後続キーを押す
M.leader = {
  key               = "q",
  mods              = "CTRL",
  timeout_milliseconds = 1000,
}

-- ==========================================
-- キーテーブル（モード別バインド）
-- ==========================================
-- LEADER + r でリサイズモードに入り、hjkl または矢印キーでペインサイズを調整する。
-- Escape または Enter でモードを抜ける。
M.key_tables = {
  resize_pane = {
    { key = "h",          action = act.AdjustPaneSize({ "Left",  2 }) },
    { key = "l",          action = act.AdjustPaneSize({ "Right", 2 }) },
    { key = "k",          action = act.AdjustPaneSize({ "Up",    2 }) },
    { key = "j",          action = act.AdjustPaneSize({ "Down",  2 }) },
    { key = "LeftArrow",  action = act.AdjustPaneSize({ "Left",  2 }) },
    { key = "RightArrow", action = act.AdjustPaneSize({ "Right", 2 }) },
    { key = "UpArrow",    action = act.AdjustPaneSize({ "Up",    2 }) },
    { key = "DownArrow",  action = act.AdjustPaneSize({ "Down",  2 }) },
    { key = "Escape",     action = "PopKeyTable" },
    { key = "Enter",      action = "PopKeyTable" },
  },
}

-- ==========================================
-- キーボードショートカット
-- ==========================================
M.keys = {

  -- ------------------------------------------
  -- クリップボード操作
  -- ------------------------------------------
  -- Ctrl+Shift+V : Paste
  {
    key    = "v",
    mods   = "CTRL|SHIFT",
    action = act.PasteFrom("Clipboard"),
  },
  -- Ctrl+Shift+C : Copy
  {
    key    = "c",
    mods   = "CTRL|SHIFT",
    action = act.CopyTo("Clipboard"),
  },

  -- ------------------------------------------
  -- 検索
  -- ------------------------------------------
  -- Ctrl+Shift+F : 前方検索
  {
    key    = "f",
    mods   = "CTRL|SHIFT",
    action = act.Search({ CaseInSensitiveString = "" }),
  },

  -- ------------------------------------------
  -- フォントサイズ操作
  -- ------------------------------------------
  -- Ctrl+0 : フォントサイズリセット
  {
    key    = "0",
    mods   = "CTRL",
    action = act.ResetFontSize,
  },

  -- ------------------------------------------
  -- タブ操作
  -- ------------------------------------------
  -- Ctrl+Shift+T : 新規タブを開く
  {
    key    = "t",
    mods   = "CTRL",
    action = act.SpawnTab("CurrentPaneDomain"),
  },
  -- Ctrl+Shift+W : 現在のタブを閉じる
  {
    key    = "w",
    mods   = "CTRL",
    action = act.CloseCurrentTab({ confirm = false }),
  },
  -- Ctrl+Tab : 次のタブへ移動
  {
    key    = "Tab",
    mods   = "CTRL",
    action = act.ActivateTabRelative(1),
  },
  -- Ctrl+Shift+Tab : 前のタブへ移動
  {
    key    = "Tab",
    mods   = "CTRL|SHIFT",
    action = act.ActivateTabRelative(-1),
  },

  -- ------------------------------------------
  -- ペイン操作（LEADER + キー）
  -- tmux の prefix キーバインドに準拠
  -- ------------------------------------------
  -- LEADER + v : ペインを左右に分割
  {
    key    = "v",
    mods   = "LEADER",
    action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },
  -- LEADER + s : ペインを上下に分割
  {
    key    = "s",
    mods   = "LEADER",
    action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
  },
  -- LEADER + x : 現在のペインを閉じる
  {
    key    = "x",
    mods   = "LEADER",
    action = act.CloseCurrentPane({ confirm = false }),
  },
  -- LEADER + z : ペインをズーム（最大化）トグル
  {
    key    = "z",
    mods   = "LEADER",
    action = act.TogglePaneZoomState,
  },

  -- ------------------------------------------
  -- ペイン移動（LEADER + h,j,k,l）
  -- ------------------------------------------
  -- LEADER+h : 左ペインへ移動
  {
    key    = "h",
    mods   = "LEADER",
    action = act.ActivatePaneDirection("Left"),
  },
  -- LEADER+l : 右ペインへ移動
  {
    key    = "l",
    mods   = "LEADER",
    action = act.ActivatePaneDirection("Right"),
  },
  -- LEADER+k : 上ペインへ移動
  {
    key    = "k",
    mods   = "LEADER",
    action = act.ActivatePaneDirection("Up"),
  },
  -- LEADER+j : 下ペインへ移動
  {
    key    = "j",
    mods   = "LEADER",
    action = act.ActivatePaneDirection("Down"),
  },

  -- ------------------------------------------
  -- ペインリサイズモード
  -- ------------------------------------------
  -- LEADER + r : リサイズモードへ入る
  -- モード中は hjkl または矢印キーで 2セルずつサイズ変更
  -- Escape または Enter でモードを抜ける
  {
    key    = "r",
    mods   = "LEADER",
    action = act.ActivateKeyTable({
      name             = "resize_pane",
      one_shot         = false,   -- Escape/Enter まで継続
      timeout_milliseconds = 5000, -- 5秒無操作で自動解除
    }),
  },

  -- ------------------------------------------
  -- コピーモード・クイックセレクト
  -- ------------------------------------------
  -- LEADER + [ : コピーモードへ入る
  {
    key    = "[",
    mods   = "LEADER",
    action = act.ActivateCopyMode,
  },
  -- Ctrl+Shift+Space : クイックセレクトモード
  -- URLやファイルパス等をキーボードで素早く選択・コピーする
  {
    key    = "Space",
    mods   = "CTRL|SHIFT",
    action = act.QuickSelect,
  },

  -- ------------------------------------------
  -- コマンドパレット
  -- ------------------------------------------
  -- Ctrl+Shift+P : コマンドパレットを開く
  {
    key    = "p",
    mods   = "CTRL|SHIFT",
    action = act.ActivateCommandPalette,
  },

  -- ------------------------------------------
  -- Ctrl+q のパススルー
  -- ------------------------------------------
  -- LEADER + Ctrl+q : Ctrl+q をそのままシェルに送る
  -- リーダーキーが Ctrl+q のため、シェルの行頭移動などに使う場合に必要
  {
    key    = "q",
    mods   = "LEADER|CTRL",
    action = act.SendKey({ key = "q", mods = "CTRL" }),
  },
}

-- ==========================================
-- マウスバインド
-- ==========================================
M.mouse_bindings = {
  -- Middle クリックで Paste
  {
    event  = { Down = { streak = 1, button = "Middle" } },
    mods   = "NONE",
    action = act.PasteFrom("PrimarySelection"),
  },
  -- ホイール上：3行スクロール（Alacritty multiplier=3 相当）
  {
    event  = { Down = { streak = 1, button = { WheelUp = 1 } } },
    mods   = "NONE",
    action = act.ScrollByLine(-3),
  },
  -- ホイール下：3行スクロール
  {
    event  = { Down = { streak = 1, button = { WheelDown = 1 } } },
    mods   = "NONE",
    action = act.ScrollByLine(3),
  },
}

return M
