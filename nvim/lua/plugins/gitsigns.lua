-- lua/plugins/gitsigns.lua
return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    -- サインの記号設定 (mini.diff と同じ見た目を維持)
    signs = {
      add          = { text = "┃" },
      change       = { text = "┃" },
      delete       = { text = "━" },
      topdelete    = { text = "‾" },
      changedelete = { text = "~" },
      untracked    = { text = "┊" },
    },
    -- staged 用のサイン (gitsigns 独自機能)
    signs_staged = {
      add          = { text = "┃" },
      change       = { text = "┃" },
      delete       = { text = "_" },
      topdelete    = { text = "‾" },
      changedelete = { text = "~" },
    },
    signs_staged_enable = true,

    -- インライン blame は手動 ON にする (デフォルト OFF が業務的に静か)
    current_line_blame = false,
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = "eol", -- 行末に表示
      delay = 500,
      ignore_whitespace = false,
    },
    current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",

    -- プレビュー UI
    preview_config = {
      border = "rounded", -- 既存設定の丸角に統一
      style = "minimal",
      relative = "cursor",
      row = 0,
      col = 1,
    },

    -- LspAttach 風の on_attach でキーマップをバッファローカル設定
    on_attach = function(bufnr)
      local gs = require("gitsigns")
      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
      end

      ----------------------------------------------------
      -- ナビゲーション (ハンク間移動)
      ----------------------------------------------------
      map("n", "]c", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        else
          gs.nav_hunk("next")
        end
      end, "Next Hunk")

      map("n", "[c", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        else
          gs.nav_hunk("prev")
        end
      end, "Prev Hunk")

      ----------------------------------------------------
      -- ハンク操作 (<leader>g* グループに統合)
      ----------------------------------------------------
      map("n", "<leader>gs", gs.stage_hunk, "Stage Hunk")
      map("n", "<leader>gr", gs.reset_hunk, "Reset Hunk")
      map("v", "<leader>gs", function()
        gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Stage Selected Hunk")
      map("v", "<leader>gr", function()
        gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
      end, "Reset Selected Hunk")
      map("n", "<leader>gS", gs.stage_buffer, "Stage Buffer")
      map("n", "<leader>gR", gs.reset_buffer, "Reset Buffer")
      map("n", "<leader>gu", gs.undo_stage_hunk, "Undo Stage Hunk")
      map("n", "<leader>gp", gs.preview_hunk, "Preview Hunk")

      ----------------------------------------------------
      -- Blame 関連
      ----------------------------------------------------
      map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame Line (full)")
      map("n", "<leader>gB", gs.toggle_current_line_blame, "Toggle Line Blame")

      ----------------------------------------------------
      -- Diff 表示切替
      ----------------------------------------------------
      map("n", "<leader>gd", gs.diffthis, "Diff This")
      map("n", "<leader>gD", function() gs.diffthis("~") end, "Diff This ~")
      map("n", "<leader>gw", gs.toggle_word_diff, "Toggle Word Diff")

      ----------------------------------------------------
      -- ハンクをテキストオブジェクトとして扱う
      ----------------------------------------------------
      map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "Select Hunk")
    end,
  },
}
