return {
  "mfussenegger/nvim-lint",
  -- ファイルを読み込んだ後、または書き込んだ後にロード
  event = { "BufReadPost", "BufWritePost", "InsertLeave" },
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      yaml = { "yamllint" },
      markdown = { "markdownlint" },
      lua = { "selene" },
    }

    -- selene.toml の置き場所を固定するため、cwdをdotfiles側に明示的に指定
    lint.linters.selene.args = vim.list_extend(
      { "--config", vim.fn.stdpath("config") .. "/selene.toml" },
      lint.linters.selene.args or {}
    )

    -- 編集や保存のタイミングで自動的にリンターを走らせるオートコマンド
    local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        lint.try_lint()
      end,
    })
  end,
}
