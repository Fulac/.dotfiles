# dotfiles

XDG Base Directory 仕様に従った、マルチディストリ対応の dotfiles リポジトリ。

CachyOS をメインに、Fedora / Ubuntu / Debian など複数のディストロで同一の設定を運用できる。

## Features

- **マルチディストリ対応** : Arch / Fedora / Debian 系のいずれでも `./bootstrap.sh` 一発で環境構築
- **XDG Base Directory 準拠** : ホームディレクトリを汚さない設定配置
- **モダン CLI ツール統合** : `eza`, `bat`, `ripgrep`, `fd`, `fzf`, `zoxide` などをデフォルト導入
- **オプション機能** : Alacritty / Starship / Neovim をニーズに応じて除外可能
- **シェル起動の高速化** : `compinit` の遅延チェック、外部コマンド補完のキャッシュ化
- **冪等性** : 何度実行しても同じ結果になる安全な設計

## Quick Start

```bash
# 1. リポジトリをクローン
git clone https://github.com/yourname/dotfiles ~/.dotfiles
cd ~/.dotfiles

# 2. 必要なツールをインストール (ディストロ自動検出)
./bootstrap.sh

# 3. 設定ファイルをシンボリックリンク展開
./deploy.sh

# 4. zsh に切り替え
exec zsh
```

これだけで、以下の環境が一度に整う:

- zsh (sheldon プラグイン管理, starship プロンプト)
- Neovim (lazy.nvim プラグイン管理, Python venv 構築済み)
- Alacritty (GPU 高速ターミナル)
- モダン CLI ツール一式

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
