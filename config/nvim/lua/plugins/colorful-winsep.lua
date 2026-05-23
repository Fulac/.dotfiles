return {
  "nvim-zh/colorful-winsep.nvim",
  event = { "WinLeave" },
  config = function()
    vim.api.nvim_set_hl(0, "ColorfulWinsep", { fg = "#426AB3", bg = "NONE" })
    require("colorful-winsep").setup({
      no_exec_files = { "packer", "TelescopePrompt", "mason", "Lazy" },
    })
  end
}
