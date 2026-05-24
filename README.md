# Quick Start

```bash
# 1. リポジトリをクローン
git https://github.com/Fulac/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# 2. 必要なツールをインストール (ディストロ自動検出)
./bootstrap.sh

# 3. 設定ファイルをシンボリックリンク展開
./deploy.sh

# 4. zsh に切り替え
exec zsh
```

## Tools and Applications

### bootstrap.sh で自動インストール

| ツール              | 役割                        | 必須       | 備考                           |
| ------------------- | --------------------------- | ---------- | ------------------------------ |
| **zsh**             | メインシェル                | ✓          |                                |
| **git**             | バージョン管理              | ✓          |                                |
| **curl**            | HTTP クライアント           | ✓          | 公式スクリプト取得用           |
| **sheldon**         | zsh プラグインマネージャ    | ✓          | Rust 製、TOML 設定             |
| **uv**              | Python パッケージマネージャ | ✓          | pip/poetry/venv の統合         |
| **bat**             | `cat` の代替                | ✓          | シンタックスハイライト         |
| **ripgrep** (rg)    | `grep` の代替               | ✓          | 高速、.gitignore尊重           |
| **fd**              | `find` の代替               | ✓          | 直感的な構文                   |
| **eza**             | `ls` の代替                 | ✓          | アイコン, git連携              |
| **fzf**             | ファジーファインダ          | ✓          | Ctrl+R で履歴検索強化          |
| **zoxide**          | `cd` の学習型代替           | ✓          | frecency でジャンプ            |
| **starship**        | シェルプロンプト            | optional   | `--without-starship` で除外可  |
| **alacritty**       | GPU高速ターミナル           | optional   | `--without-alacritty` で除外可 |
| **neovim**          | エディタ                    | optional   | `--without-neovim` で除外可    |
| **nodejs/npm**      | Neovim プラグイン依存       | neovim連動 | LSP, tree-sitter で使用        |
| **tree-sitter-cli** | パーサビルドツール          | neovim連動 | nvim-treesitter で使用         |

### bootstrap.sh のオプション

```bash
# デフォルト (全てインストール)
./bootstrap.sh

# サーバー環境 (alacritty なし)
./bootstrap.sh --without-alacritty

# 最小構成 (neovim 関連を除外)
./bootstrap.sh --without-neovim

# 複数除外
./bootstrap.sh --without-alacritty --without-neovim

# 実行内容の確認のみ (実際にはインストールしない)
DRY_RUN=1 ./bootstrap.sh

# ヘルプ
./bootstrap.sh --help
```

### deploy.sh のモード

```bash
# クライアント (デスクトップ環境、デフォルト)
./deploy.sh
./deploy.sh client

# サーバー (headless 環境、Alacritty を除外)
./deploy.sh --server

# アンインストール (全 symlink を削除)
./deploy.sh --uninstall
```
