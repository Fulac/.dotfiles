return {
  'saghen/blink.cmp',
  version = "1.*",
  event = { "InsertEnter", "CmdLineEnter" },
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    -- 1. appearance (エディタ全体の見た目の基本設定)
    appearance = {
      nerd_font_variant = "mono",
    },

    -- 2. keymap (通常の文字入力モードでのキーマップ)
    keymap = {
      preset = "enter",
      -- change TAB, S-TAB
      ['<Tab>'] = {
        function(cmp)
          if cmp.snippet_active() then return cmp.accept() end
          -- 内部モジュールへのアクセスを pcall で保護
          local ok, list = pcall(require, 'blink.cmp.completion.list')
          if ok and #list.items == 1 then
            return cmp.select_and_accept()
          end
          return cmp.select_next()
        end,
        'snippet_forward',
        'fallback'
      },
      ['<S-Tab>'] = {
        function(cmp)
          if not cmp.snippet_active() then
            -- 内部モジュールへのアクセスを pcall で保護
            local ok, list = pcall(require, 'blink.cmp.completion.list')
            if ok and #list.items == 1 then
              return cmp.select_and_accept()
            end
            return cmp.select_prev()
          end
        end,
        'snippet_backward',
        'fallback'
      },
    },

    -- 3. sources (補完データソースの定義)
    sources = {
      default = { "lsp", "snippets", "path", "buffer" },

      min_keyword_length = function(ctx)
        if ctx.mode == "cmdline" then
          -- 小文字 + 任意の ! で構成される短いコマンドはポップアップしない
          -- 対象例: :w, :q, :wq, :qa, :w!, :q!, :wq!, :qa!
          -- 非対象例: :Lazy, :Mason, :wqa (3文字以上の小文字コマンド)
          if ctx.line:find("^%l+!?$") ~= nil then
            return 3
          end
          return 0
        end
        return 0
      end,

      -- ソース別の min_keyword_length は providers 側で定義
      providers = {
        buffer = {
          min_keyword_length = 2, -- バッファ補完は2文字以上で起動
        },
      },
    },

    -- 4. completion (補完メニューや説明文ウィンドウの詳細)
    completion = {
      documentation = {
        auto_show = true,         -- 候補選択時に自動でドキュメントを表示
        auto_show_delay_ms = 200, -- 200ms 後に表示
        window = { border = "rounded" },
      },
      menu = { border = "rounded" },
      list = { selection = { preselect = false } }, -- auto select false
    },

    -- 5. signature (関数の引数ガイドウィンドウの設定)
    signature = {
      enabled = true,
      window = { border = "rounded" },
    },

    -- 6. cmdline (サブモード：コマンドライン専用の個別オーバーライド)
    cmdline = {
      sources = { "cmdline" },
      keymap = { preset = "cmdline", },
      completion = {
        menu = { auto_show = true },
        list = { selection = { preselect = false } },
      },
    },

    -- 7. fuzzy (検索エンジンの最適化)
    fuzzy = {
      implementation = "prefer_rust",
    },
  },
  opts_extend = { "sources.default" },

  config = function(_, opts)
    local border_color = "#504945"

    -- ハイライト設定を関数化して再利用可能にする
    local function apply_hl()
      vim.api.nvim_set_hl(0, 'BlinkCmpMenu', { bg = 'NONE' })
      vim.api.nvim_set_hl(0, 'BlinkCmpMenuBorder', { fg = border_color, bg = 'NONE' })
      vim.api.nvim_set_hl(0, 'BlinkCmpDoc', { bg = 'NONE' })
      vim.api.nvim_set_hl(0, 'BlinkCmpDocBorder', { fg = border_color, bg = 'NONE' })
      vim.api.nvim_set_hl(0, 'BlinkCmpSignatureHelp', { bg = 'NONE' })
      vim.api.nvim_set_hl(0, 'BlinkCmpSignatureHelpBorder', { fg = border_color, bg = 'NONE' })
    end

    apply_hl()

    -- ColorScheme 変更時に再適用
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("BlinkCmpColors", { clear = true }),
      callback = apply_hl,
    })

    require('blink.cmp').setup(opts)
  end,
}
