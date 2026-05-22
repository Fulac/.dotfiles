---------------------------------------------
-- package manager
---------------------------------------------
--  lazy.nvim
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

local plugins = {
  { import = 'plugins' },
}

local opts = {
  defaults = {
    lazy = true
  },
  ui = {
    border = "rounded", -- 外枠の線を丸角にする（"single" や "double" にも変更可能）
  },
  rocks = {
    enabled = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        'netrw',
        'netrwPlugin',
        'netrwSettings',
        'netrwFileHandlers',
        'gzip',
        'zip',
        'zipPlugin',
        'tar',
        'tarPlugin',
        'getscript',
        'getscriptPlugin',
        'vimballPlugin',
        '2html_Plugin',
        'logipat',
        'rrhelper',
        'spellfile_plugin',
        'sql_completion',
      },
    },
  },
}

-- Any lua file in ~/.config/nvim/lua/pulgins/*.lua will be automatically merged
require('lazy').setup(plugins, opts)
