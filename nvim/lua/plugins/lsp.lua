return {
  -----------------------------------------------------------------------------
  -- 1. Mason: LSPサーバー等のローカルパッケージマネージャー
  -----------------------------------------------------------------------------
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>lm", "<cmd>Mason<cr>", desc = "Mason Management" } },
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
      -- 共通: グローバル LSP UI 設定 (枠線・診断表示)
      vim.diagnostic.config({
        float = { border = "rounded" },
        virtual_text = { prefix = "●" },
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.HINT] = " ",
            [vim.diagnostic.severity.INFO] = " ",
          },
        },
      })

      -- グローバルな LSP キーマップ設定 (LspAttach オートコマンド)
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
        callback = function(ev)
          local bufnr = ev.buf
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
          end

          -- gd: 定義元へジャンプ
          map("n", "gd", vim.lsp.buf.definition, "Go to Definition")

          -- K: カーソル下の関数などの説明書(ドキュメント)をポップアップ表示
          map("n", "K", function()
            vim.lsp.buf.hover({ border = "rounded" })
          end, "Hover Documentation")

          -- <leader>cr: 安全一括置換 (Rename Symbol)
          map("n", "<leader>cr", vim.lsp.buf.rename, "Rename Symbol")

          -- <leader>ca: コードアクション (クイックフィックス等の自動修正提案)
          map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")

          -- gr: 参照元一覧
          map("n", "gr", vim.lsp.buf.references, "References")

          -- gi: 実装へジャンプ
          map("n", "gi", vim.lsp.buf.implementation, "Go to Implementation")

          -- gD: 宣言へジャンプ
          map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")

          -- 標準オートコンプリート / インレイヒント の有効化
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client then
            -- インレイヒント (対応サーバーのみ。<leader>ch でトグル)
            if client:supports_method("textDocument/inlayHint") then
              vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
              map("n", "<leader>ch", function()
                vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
              end, "Toggle Inlay Hints")
            end

            -- ドキュメントハイライト (カーソル下のシンボルを自動ハイライト)
            if client:supports_method("textDocument/documentHighlight") then
              local hl_group = vim.api.nvim_create_augroup("LspDocumentHighlight", { clear = false })
              vim.api.nvim_clear_autocmds({ buffer = bufnr, group = hl_group })
              vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                group = hl_group,
                buffer = bufnr,
                callback = vim.lsp.buf.document_highlight,
              })
              vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
                group = hl_group,
                buffer = bufnr,
                callback = vim.lsp.buf.clear_references,
              })
            end
          end
        end,
      })

      -- :lsp サブコマンドのショートカット
      -- vim.lspのcheck health
      vim.keymap.set("n", "<leader>li", "<cmd>checkhealth vim.lsp<cr>", { desc = "LSP Info (checkhealth)" })

      -- 全LSPクライアント再起動
      vim.keymap.set("n", "<leader>lr", function()
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        for _, c in ipairs(clients) do
          vim.cmd("LspRestart " .. c.name) -- 互換ラッパが残っている場合に備える
        end
        if #clients == 0 then
          vim.notify("No active LSP clients", vim.log.levels.WARN)
        end
      end, { desc = "Restart LSP Clients" })

      -- LSPログをtail表示
      vim.keymap.set(
        "n",
        "<leader>ll",
        "<cmd>lua vim.cmd('split | terminal tail -f ' .. vim.lsp.get_log_path())<cr>",
        { desc = "Tail LSP Log" }
      )

      -- blink.cmpからLSPの「ファジー補完能力」を抽出して結合
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)

      -- vim.lsp.config('*', ...) で「全サーバー共通」の設定をブロードキャスト
      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      -----------------------------------------------------------------------------
      -- 各言語サーバー設定
      -----------------------------------------------------------------------------

      -- Lua (lua_ls)
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = {
              checkThirdParty = false,
              library = vim.api.nvim_get_runtime_file("", true), -- Neovim ランタイムを認識
            },
            diagnostics = {
              globals = { "vim" },    -- "vim" 変数への未定義警告を抑止
            },
            hint = { enable = true }, -- インレイヒントを有効化
            telemetry = { enable = false },
          },
        },
      })

      -- C / C++ (clangd)
      vim.lsp.config("clangd", {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders=1",
        },
      })

      -- Python (pyright + ruff)
      vim.lsp.config("pyright", {
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              diagnosticMode = "openFilesOnly",
              useLibraryCodeForTypes = true,
              typeCheckingMode = "basic",
            },
          },
        },
      })
      vim.lsp.config("ruff", {
        -- ruff は lint/format 専属。hover などは pyright に任せる
        on_attach = function(client, _)
          client.server_capabilities.hoverProvider = false
        end,
      })

      -- YAML (yamlls) - Ansible 用ファイルは ansiblels に任せるためフィルタ
      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            telemetry = { enable = false },
            validate = true,
            keyOrdering = false, -- Ansible playbook 等でキー順序を強制しない
            schemaStore = {
              enable = true,
              url = "https://www.schemastore.org/api/json/catalog.json",
            },
          },
          redhat = { telemetry = { enabled = false } },
        },
      })

      -- JSON (jsonls)
      vim.lsp.config("jsonls", {
        settings = {
          json = {
            validate = { enable = true },
            telemetry = { enable = false },
          },
        },
      })

      -- Markdown (marksman)
      vim.lsp.config("marksman", {})

      -- シェルスクリプト (bashls) - zsh ファイルも対象に
      vim.lsp.config("bashls", {
        filetypes = { "sh", "bash", "zsh" },
        settings = {
          bashIde = {
            -- shellcheck と連携 (mason 経由でインストールされていれば自動検出)
            shellcheckPath = "shellcheck",
          },
        },
      })

      -----------------------------------------------------------------------------
      -- mason-lspconfig の初期設定（自動インストール登録）
      -----------------------------------------------------------------------------
      require("mason-lspconfig").setup({
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
        -- automatic_enable はデフォルト true。明示しておく
        automatic_enable = true,
      })
    end,
  },
}
