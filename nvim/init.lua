----------------------------------------------
-- key mapping
----------------------------------------------
-- jf でノーマルモードへ戻る
vim.keymap.set("i", "jf", "<ESC>")
vim.keymap.set("i", "ｊｆ", "<ESC>")

-- 検索のハイライトを解除する (<Esc><Esc>で)
vim.keymap.set("n", "<ESC><ESC>", ":nohlsearch<CR><ESC>")

-- 押しづらいキーを置き換える
vim.keymap.set("n", "H", "^")
vim.keymap.set("n", "L", "$")

-- ウィンドウ移動(上、下、左、右、次)
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- タブ移動(次、前)
vim.keymap.set("n", "tt", "gt")
vim.keymap.set("n", "tr", "gT")

-- <Leader>を<Space>に割り当てる
vim.g.mapleader = " "

-- <LocalLeader>をカンマに割り当てる
vim.g.maplocalleader = ","

----------------------------------------------
-- ファイル処理関連の設定
----------------------------------------------
-- 保存されてないファイルがあるときは終了前に保存確認
vim.opt.confirm = true

-- 保存されてないファイルがあるときでも別のファイルを開く事ができる
vim.opt.hidden = true

-- 外部でファイルに変更がされた場合は読み直す
vim.opt.autoread = true

-- ファイル保存時にバックアップファイルを作らない
vim.opt.backup = false

-- ファイル編集中にスワップファイルを作らない
vim.opt.swapfile = false

----------------------------------------------
-- 検索/置換の設定
-----------------------------------------------
-- 検索文字をハイライトする
vim.opt.hlsearch = true

-- インクリメンタルサーチを行う
vim.opt.incsearch = true

-- 大文字と小文字を区別しない
vim.opt.ignorecase = true

-- 大文字と小文字が混在した言葉で検索を行った場合に限り、大文字と小文字を区別する
vim.opt.smartcase = true

-- 最後尾まで検索を終えたら次の検索で先頭に移る
vim.opt.wrapscan = true

----------------------------------------------
-- タブ/インデントの設定
----------------------------------------------
-- タブ入力を複数の空白入力に置き換える
vim.opt.expandtab = true

-- 画面入力でタブ文字が占める幅
vim.opt.tabstop = 2

-- 自動インデントでずれる幅
vim.opt.shiftwidth = 2

-- 連続した空白に対してタブキーやバックスペースキーでカーソルが動く幅
vim.opt.softtabstop = 2

-- 改行時に前の行のインデントを継承する
vim.opt.autoindent = true

----------------------------------------------
-- 動作環境との統合関連の設定
----------------------------------------------
-- マウスの入力を受け付ける
vim.opt.mouse = "a"

----------------------------------------------
-- ビープの設定
----------------------------------------------
-- ビープ音をビジュアルベルに置き換える
vim.opt.visualbell = true

-- エラーメッセージの表示時にビープを鳴らさない
vim.opt.errorbells = false

----------------------------------------------
-- 文字コードの設定
----------------------------------------------
-- 内部処理コードの設定
vim.opt.encoding = "utf-8"

-- 空ファイルの文字コードの設定
vim.opt.fileencoding = "utf-8"

-- 既存ファイルの文字コード優先設定
vim.opt.fileencodings = { "ucs-bom", "utf-8", "iso-2022", "cp932", "default", "latin" }

-- Ambiguous Width Charactersの設定
-- 表示が崩れる特定の文字（コードポイント）だけをピンポイントで「幅2」に強制上書きする
vim.opt.ambiwidth = "single"
vim.fn.setcellwidths({
  { 0x2026, 0x2026, 2 }, -- … (三点リーダー)
  { 0x203b, 0x203b, 2 }, -- ※ (米印)
  { 0x25a0, 0x25a0, 2 }, -- ■ (四角)
  { 0x25b2, 0x25b2, 2 }, -- ▲ (三角)
  { 0x2192, 0x2192, 2 }, -- → (右矢印)
})

-- Menuの言語設定
vim.opt.langmenu = "none"

----------------------------------------------
-- vimの色関係
----------------------------------------------
-- ハイライト on
vim.opt.syntax = "on"

vim.opt.termguicolors = true

----------------------------------------------
-- 画面表示の設定
----------------------------------------------
-- 行番号を表示する
vim.opt.number = true

-- 編集行の行番号をハイライトする
vim.opt.cursorline = true

-- ステータス行を常に表示
vim.opt.laststatus = 3

-- メッセージ表示欄を２行確保
vim.opt.cmdheight = 2

-- 対応する括弧を強調表示
vim.opt.showmatch = true

-- 対応括弧の表示秒数３秒
vim.opt.matchtime = 3

-- ヘルプを画面一杯に開く
vim.opt.helpheight = 999

-- 不可視文字を表示
vim.opt.list = true

-- 不可視文字の表示記号設定
vim.opt.listchars = "tab:>-,extends:>,precedes:<"

-- モードの表示を消す
vim.opt.showmode = false

-- 縦分割を右側に開く
vim.opt.splitright = true

----------------------------------------------
-- カーソル移動関連の設定
----------------------------------------------
-- Backspaceキーの影響範囲に制限を設けない
vim.opt.backspace = { "indent", "eol", "start" }

-- 行頭行末の左右移動で行をまたぐ
vim.opt.whichwrap = "b,s,h,l,<,>,[,]"

-- 上下８行の視界確保
vim.opt.scrolloff = 8

-- 左右スクロール時の視界を確保
vim.opt.sidescrolloff = 16

-- 左右スクロールは１文字づつ行う
vim.opt.sidescroll = 1

----------------------------------------------
-- 記号(utf-8)の幅設定(status lineのセパレータがずれる対策)
----------------------------------------------
local cellwidths = vim.fn.getcellwidths()

-- Unicode Standard Miscellaneous Symbols
table.insert(cellwidths, { 0x2600, 0x26ff, 1 })

-- Seti-UI + Custom
table.insert(cellwidths, { 0xe5fa, 0xe6ac, 1 })

-- Devicons
table.insert(cellwidths, { 0xe700, 0xe7c5, 1 })

-- Font Awesome
table.insert(cellwidths, { 0xf000, 0xf2e0, 1 })

-- Font Awesome Extension
table.insert(cellwidths, { 0xe200, 0xe2a9, 1 })

-- Material Design Icons
table.insert(cellwidths, { 0xf0001, 0xf1af0, 1 })

-- Weather
table.insert(cellwidths, { 0xe300, 0xe3e3, 1 })

-- Octicons
table.insert(cellwidths, { 0xf400, 0xf532, 1 })

-- Powerline Symbols
table.insert(cellwidths, { 0xe0a0, 0xe0a2, 1 })
table.insert(cellwidths, { 0xe0b0, 0xe0b3, 1 })

-- Powerline Extra Symbols
table.insert(cellwidths, { 0xe0a3, 0xe0a3, 1 })
table.insert(cellwidths, { 0xe0b4, 0xe0c8, 1 })
table.insert(cellwidths, { 0xe0ca, 0xe0ca, 1 })
table.insert(cellwidths, { 0xe0cc, 0xe0d4, 1 })

-- IEC Power Symbols
table.insert(cellwidths, { 0x23fb, 0x23fe, 1 })
table.insert(cellwidths, { 0x2b58, 0x2b58, 1 })

-- Font Logos
table.insert(cellwidths, { 0xf300, 0xf32f, 1 })

-- Pomicons
table.insert(cellwidths, { 0xe000, 0xe00a, 1 })

-- Codicons
table.insert(cellwidths, { 0xea60, 0xebeb, 1 })

-- Heavy Angle Brackets
table.insert(cellwidths, { 0x276c, 0x2771, 1 })

-- Box Drawing
table.insert(cellwidths, { 0x2500, 0x259f, 1 })

vim.fn.setcellwidths(cellwidths)

----------------------------------------------
-- Install Plugin
----------------------------------------------
-- lazy.nvim
require("lazy_nvim")

----------------------------------------------
-- os個別設定
----------------------------------------------
if vim.fn.has("win64") == 1 then
  OSTYPE = "Windows"
else
  OSTYPE = "Linux"
end

if OSTYPE == "Linux" then
  -- python3のパス設定
  vim.g.python3_host_prog = vim.fn.expand("~/.local/share/nvim/venv/bin/python")
elseif OSTYPE == "Windows\n" then
  -- python3のパス設定
  vim.g.python3_host_prog = vim.fn.expand("C:/Users/fulac/Programs/Python/Python38/python")
end
