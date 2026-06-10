local wezterm = require("wezterm")
local config = wezterm.config_builder()

-- ==========================================
-- フォント設定
-- ==========================================
config.font = wezterm.font_with_fallback({
  { family = "Bizin Gothic NF", weight = "Regular" },
})

config.font_size = 12

-- フォントサイズ変更時にウィンドウサイズを固定し行列数を変化させる
config.adjust_window_size_when_changing_font_size = false

-- ==========================================
-- ウィンドウ・外観設定
-- ==========================================
-- 背景の透過度
config.window_background_opacity = 0.9

-- 起動時のウィンドウサイズ
config.initial_cols = 140
config.initial_rows = 45

-- ウィンドウのパディング
config.window_padding = {
  left = 2,
  right = 2,
  top = 0,
  bottom = 0,
}

-- ==========================================
-- カラーパレット
-- ==========================================
config.colors = {
  -- Primary
  background = "#0a0c11",
  foreground = "#c3d7d1",

  -- Cursor
  cursor_bg = "#c3d7d1",
  cursor_fg = "#0a0c11",
  cursor_border = "#c3d7d1",

  -- Normal (palette 0-7)
  ansi = {
    "#282c34", -- 0: black
    "#e05441", -- 1: red
    "#6db86d", -- 2: green
    "#bfb143", -- 3: yellow
    "#4c77e6", -- 4: blue
    "#c943be", -- 5: magenta
    "#36cccc", -- 6: cyan
    "#dcdfe4", -- 7: white
  },

  -- Bright (palette 8-15)
  brights = {
    "#5c6370", -- 8:  bright black
    "#f76b59", -- 9:  bright red
    "#8ce68c", -- 10: bright green
    "#e6d34e", -- 11: bright yellow
    "#7196f8", -- 12: bright blue
    "#f55be9", -- 13: bright magenta
    "#66f2f2", -- 14: bright cyan
    "#ffffff", -- 15: bright white
  },

  -- タブバー
  tab_bar = {
    background = "#0a0c11",
    new_tab = {
      bg_color = "#0a0c11",
      fg_color = "#5c6370",
    },
    new_tab_hover = {
      bg_color = "#0a0c11",
      fg_color = "#c3d7d1",
    },
  },
}

-- bold テキストを bright カラーで描画
config.bold_brightens_ansi_colors = true

-- リバースビデオモードを有効にする
config.force_reverse_video_cursor = true

-- 非アクティブペインを暗くして視覚的に区別する
config.inactive_pane_hsb = {
  saturation = 0.8, -- 彩度を下げる（1.0 が元の色）
  brightness = 0.6, -- 輝度を下げる（1.0 が元の輝度）
}

-- ==========================================
-- タブバー設定
-- ==========================================
-- タブバーを表示
config.enable_tab_bar = true

-- タブが1枚だけの時はタブバーを非表示にする
config.hide_tab_bar_if_only_one_tab = true

-- レトロスタイルのタブバーを使用する（format-tab-title イベントに必要）
config.use_fancy_tab_bar = false

-- タブバーをウィンドウ下部に配置する場合は true に変更
config.tab_bar_at_bottom = false

-- 1タブあたりの最大表示幅（文字数）
config.tab_max_width = 32

-- 区切り文字
local ARROW_LEFT  = wezterm.nerdfonts.ple_lower_right_triangle
local ARROW_RIGHT = wezterm.nerdfonts.ple_upper_left_triangle

wezterm.on("format-tab-title", function(tab, tabs, panes, cfg, hover, max_width)
  local tab_bg = "#1a1e2a"
  local tab_fg = "#5c6370"
  if tab.is_active then
    tab_bg = "#b5c42f"
    tab_fg = "#0a0c11"
  elseif hover then
    tab_bg = "#252b3b"
    tab_fg = "#c3d7d1"
  end

  local title = "  " .. wezterm.truncate_right(
    string.format("%d: %s", tab.tab_index + 1, tab.active_pane.title),
    max_width - 6
  ) .. "  "

  return {
    { Background = { Color = "#0a0c11" } },
    { Foreground = { Color = tab_bg } },
    { Text = ARROW_LEFT },
    { Background = { Color = tab_bg } },
    { Foreground = { Color = tab_fg } },
    { Attribute = { Intensity = tab.is_active and "Bold" or "Normal" } },
    { Text = title },
    { Background = { Color = "#0a0c11" } },
    { Foreground = { Color = tab_bg } },
    { Text = ARROW_RIGHT },
  }
end)

-- ==========================================
-- Leaderキー・キーバインド設定
-- ==========================================
local keybindings     = require("keybindings")

config.leader         = keybindings.leader
config.keys           = keybindings.keys
config.key_tables     = keybindings.key_tables
config.mouse_bindings = keybindings.mouse_bindings

-- ==========================================
-- カーソル設定
-- ==========================================
-- cursor-style = block
config.default_cursor_style = "SteadyBlock"

-- thickness = 0.15 → 0.0-1.0 の割合で指定
config.cursor_thickness = "15%"

-- ==========================================
-- スクロール設定
-- ==========================================
-- scrollback-limit = 10000 (デフォルト 3500)
config.scrollback_lines = 10000

-- ==========================================
-- 選択挙動
-- ==========================================
-- copy-on-select: 選択時に自動でクリップボードへコピー
config.selection_word_boundary = " \t\n{}[]()\"'`,;:"

-- ==========================================
-- 環境変数
-- ==========================================
config.set_environment_variables = {
  TERM = "xterm-256color",
}

-- ==========================================
-- その他
-- ==========================================
config.automatically_reload_config = true -- 設定変更を自動反映
config.audible_bell = "Disabled" -- ビープ音を無効化（デフォルト: "SystemBeep"）
config.window_close_confirmation = "NeverPrompt" -- ウィンドウを閉じる際の確認ダイアログを表示しない

return config
