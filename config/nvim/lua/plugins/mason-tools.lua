return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  dependencies = { "williamboman/mason.nvim" },
  event = "VeryLazy",
  opts = {
    -- ここに記述したLinter/Formatterが、起動時にMason経由で自動インストールされる
    ensure_installed = {
      -- リンター
      "yamllint",
      "markdownlint",
      "selene",
      -- フォーマッター
      "prettier",
      "clang-format",
      "ruff_format",
    },
    auto_update = false,
    run_on_start = false,
  },
  config = function(_, opts)
    -- 1. lsp.luaの設定（丸角UIなど）を生かしたまま、masonを安全に強制ロード
    local lazy = require("lazy")
    lazy.load({ plugins = { "mason.nvim" } })

    -- 2. mason-tool-installerのセットアップを実行
    require("mason-tool-installer").setup(opts)

    -- 3. 起動イベントが過ぎているため、100ms後にバックグラウンドでインストールを明示的にキック
    vim.defer_fn(function()
      vim.cmd("MasonToolsInstall")
    end, 100)
  end,
}
