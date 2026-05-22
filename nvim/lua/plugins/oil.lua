return {
  "stevearc/oil.nvim",
  dependencies = { "echasnovski/mini.icons" },
  lazy = false,
  opts = {
    default_file_explorer = true,
    columns = { "icon" },
    skip_confirm_for_simple_edits = true,
    view_options = {
      show_hidden = true,
    },
    -- フローティングウィンドウの見た目の設定
    float = {
      padding = 2,
      max_width = 0.8,    -- ウィンドウの最大幅（文字数、または0.8のような画面比率も可）
      max_height = 0.8,   -- ウィンドウの最大高さ
      border = "rounded", -- 枠線のスタイル（"rounded" | "single" | "double" | "shadow"）
      win_options = {
        winblend = 10,    -- ウィンドウの透過度（0で完全不透過。お好みで 10 などに）
      },
    },
    keymaps = {
      ["g?"]    = "actions.show_help",
      ["<CR>"]  = "actions.select",
      ["<C-s>"] = { "actions.select", opts = { horizontal = true }, desc = "水平分割で開く" },
      ["<C-v>"] = { "actions.select", opts = { vertical = true }, desc = "垂直分割で開く" },
      ["<C-t>"] = { "actions.select", opts = { tab = true }, desc = "新しいタブで開く" },
      ["<C-p>"] = "actions.preview",
      ["<C-c>"] = "actions.close",    -- フローティングを閉じる
      ["<Esc>"] = "actions.close",    -- フローティングを閉じる
      ["q"]     = "actions.close",    -- フローティングを閉じる
      ["<C-l>"] = "actions.refresh",
      ["-"]     = "actions.parent",   -- 親ディレクトリへ移動
      ["_"]     = "actions.open_cwd", -- カレントディレクトリへ移動
      ["g."]    = "actions.toggle_hidden",
    },
  },

  -- '-'キーでOilを開く
  init = function()
    vim.keymap.set("n", "-", function()
      require("oil").open_float()
    end, { desc = "Open oil in floating window" })
  end,
}
