return {
  {
    "delphinus/md-render.nvim",
    cmd = { "MdRender" },
    ft = { "markdown" },
    dependencies = {
      { "echasnovski/mini.icons" }, -- アイコン用
      { "delphinus/budoux.lua" },   -- 日本語の綺麗な改行用
    },
    keys = {
      { "<leader>mr", "<cmd>MdRender toggle<cr>",     desc = "Toggle Markdown Render" },
      { "<leader>ms", "<cmd>vert MdRender split<cr>", desc = "Split Markdown Render" },
    },
  },
}
