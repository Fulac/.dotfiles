return {
  'saghen/blink.cmp', 
  version = "*",
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
          if cmp.snippet_active() then return cmp.accept()
          else 
            local list = require('blink.cmp.completion.list')
            if #list.items == 1 then
              return cmp.select_and_accept()
            else
              return cmp.select_next()
            end
          end
        end,
        'snippet_forward',
        'fallback'
      },
      ['<S-Tab>'] = {
        function(cmp)
          if cmp.snippet_active() then return cmp.accept()
          else 
            local list = require('blink.cmp.completion.list')
            if #list.items == 1 then
              return cmp.select_and_accept()
            else
              return cmp.select_prev()
            end
          end
        end,
        'snippet_backward',
        'fallback'
      },
    },

    -- 3. sources (補完データソースの定義)
    sources = {
      default = { "snippets", "lsp", "path", "buffer", "cmdline" },

      min_keyword_length = function(ctx)
        -- :wq, :qa -> menu doesn't popup
        -- :Lazy, :wqa -> menu popup
        if ctx.mode == "cmdline" and ctx.line:find("^%l+$") ~= nil then
          return 3
        end
        return 0
      end,
    },

    -- 4. completion (補完メニューや説明文ウィンドウの詳細)
    completion = {
      documentation = { window = { border = "rounded" } },
      menu = { border = "rounded" },
      list = { selection = { preselect = false } }, -- auto select false
    },

    -- 5. signature (関数の引数ガイドウィンドウの設定)
    signature = { window = { border = "rounded" } },

    -- 6. cmdline (サブモード：コマンドライン専用の個別オーバーライド)
    cmdline = {
      keymap = {
        preset = "cmdline",
      },
      completion = {
        menu = { auto_show = true },
        list = { selection = { preselect = false } },
      },
    },

    -- 7. fuzzy (検索エンジンの最適化)
    fuzzy = {
      implementation = "prefer_rust_with_warning",
    },
  },
  opts_extend = { "sources.default" },

  config = function(_, opts)
    local border_color = "#504945"

    vim.api.nvim_set_hl(0, 'BlinkCmpMenu', { bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'BlinkCmpMenuBorder', { fg = border_color, bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'BlinkCmpDoc', { bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'BlinkCmpDocBorder', { fg = border_color, bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'BlinkCmpSignatureHelp', { bg = 'NONE' })
    vim.api.nvim_set_hl(0, 'BlinkCmpSignatureHelpBorder', { fg = border_color, bg = 'NONE' })

    require('blink.cmp').setup(opts)
  end,
}
