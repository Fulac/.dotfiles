return {
  -----------------------------------------------------------------------------
  -- 1. Mason: LSPサーバー等のローカルパッケージマネージャー
  -----------------------------------------------------------------------------
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason Management" } },
    opts = {
      ui = {
        border = "rounded", -- Mason管理画面の外枠も丸角に統一
        -- 起動時・画面オープン時の更新チェックをスキップ
        -- check_outdated_packages_on_open = false,
      },
    },
  },

  -----------------------------------------------------------------------------
  -- 2. nvim-lspconfig: LSP設定
  -----------------------------------------------------------------------------
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" }, -- ファイルを開いた瞬間に遅延ロード
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      local mason_lspconfig = require("mason-lspconfig")

      -- グローバルな LSP キーマップ設定 (LspAttach オートコマンド)
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local bufnr = ev.buf
          local opts = { buffer = bufnr, silent = true }

          -- gd: 定義元へジャンプ
          vim.keymap.set(
            "n",
            "gd",
            vim.lsp.buf.definition,
            vim.tbl_deep_extend("force", opts, { desc = "Go to Definition" })
          )

          -- K: カーソル下の関数などの説明書（ドキュメント）をポップアップ表示
          vim.keymap.set("n", "K", function()
            vim.lsp.buf.hover({ border = "rounded" })
          end, vim.tbl_deep_extend("force", opts, { desc = "Hover Documentation" }))

          -- <leader>cr: 安全一括置換
          vim.keymap.set(
            "n",
            "<leader>cr",
            vim.lsp.buf.rename,
            vim.tbl_deep_extend("force", opts, { desc = "Rename Symbol" })
          )
          -- <leader>ca: クイックフィックスやコードの自動修正を提案
          vim.keymap.set(
            "n",
            "<leader>ca",
            vim.lsp.buf.code_action,
            vim.tbl_deep_extend("force", opts, { desc = "Code Action" })
          )
        end,
      })

      -- blink.cmpからLSPの「ファジー補完能力」を抽出して結合
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)

      -- エラー詳細ウィンドウの枠線も rounded に固定
      vim.diagnostic.config({
        float = { border = "rounded" },
      })

      -----------------------------------------------------------------------------
      -- 各言語サーバー設定
      -----------------------------------------------------------------------------

      -- Lua用設定 (lua_ls)
      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" }, -- "vim" 変数への未定義警告を完全にシャットアウト
            },
            telemetry = { enable = false }, -- バックグラウンドのテレメトリを無効化
          },
        },
      })

      -- C / C++ 用設定 (clangd)
      vim.lsp.config("clangd", { capabilities = capabilities })

      -- Python用設定 (pyright)
      vim.lsp.config("pyright", { capabilities = capabilities })
      vim.lsp.config("ruff", { capabilities = capabilities })

      -- YAML用設定 (yamlls)
      vim.lsp.config("yamlls", {
        capabilities = capabilities,
        settings = {
          yaml = {
            telemetry = { enable = false }, -- バックグラウンドのテレメトリを無効化
            validate = true, -- ネットワーク機器のConfigやPlaybookで不意なスキーマエラーを出さない
          },
        },
      })

      -- JSON用設定 (jsonls)
      vim.lsp.config("jsonls", {
        capabilities = capabilities,
        settings = {
          json = {
            telemetry = { enable = false },
          },
        },
      })

      -- Markdown用設定 (marksman)
      vim.lsp.config("marksman", { capabilities = capabilities })

      -- シェルスクリプト用設定（sh, bash, zsh）
      vim.lsp.config("bashls", {
        capabilities = capabilities,
        filetypes = { "sh", "bash", "zsh" }, -- zshファイルでもLSPを有効化
      })

      -----------------------------------------------------------------------------
      -- mason-lspconfig の初期設定（自動インストール登録）
      -----------------------------------------------------------------------------
      mason_lspconfig.setup({
        ensure_installed = {
          "lua_ls",
          "clangd",
          "pyright",
          "ruff",
          "yamlls",
          "jsonls",
          "marksman",
          "bashls",
        },
      })
    end,
  },
}
