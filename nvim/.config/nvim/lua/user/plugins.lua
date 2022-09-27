local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim',
    install_path })
  vim.cmd [[packadd packer.nvim]]
end

return require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'

  use 'folke/tokyonight.nvim'
  use 'navarasu/onedark.nvim'
  use "ellisonleao/gruvbox.nvim"
  use "savq/melange"

  use 'kyazdani42/nvim-web-devicons'
  use 'kyazdani42/nvim-tree.lua'
  use 'romgrk/barbar.nvim'
  use 'nvim-lualine/lualine.nvim'
  use 'rmagatti/auto-session'
  use 'rmagatti/session-lens'

  use 'nvim-lua/plenary.nvim' -- Useful lua functions used by lots of plugins
  use "lewis6991/impatient.nvim" -- Speed up loading Lua modules in Neovim to improve startup time.
  use "antoinemadec/FixCursorHold.nvim" -- This is needed to fix lsp doc highlight

  use 'tpope/vim-surround'
  use "phaazon/hop.nvim"

  use {
    "ethanholz/nvim-lastplace",
    event = "BufRead",
    config = function()
      require("nvim-lastplace").setup({
        lastplace_ignore_buftype = { "quickfix", "nofile", "help" },
        lastplace_ignore_filetype = {
          "gitcommit",
          "gitrebase",
          "svn",
          "hgcommit",
        },
        lastplace_open_folds = true,
      })
    end,
  }

  use {
    "folke/which-key.nvim",
    config = function()
      require("which-key").setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
    end
  }

  use "nvim-telescope/telescope.nvim"
  use 'numToStr/Comment.nvim'
  use 'JoosepAlviste/nvim-ts-context-commentstring'
  use "lukas-reineke/indent-blankline.nvim"

  use {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
  }

  -- LSP
  use "neovim/nvim-lspconfig" -- enable LSP
  use "williamboman/nvim-lsp-installer" -- simple to use language server installer
  use "tamago324/nlsp-settings.nvim" -- language server settings defined in json for
  use "jose-elias-alvarez/null-ls.nvim" -- inject LSP diagnostics, code actions, and more
  use "folke/trouble.nvim"
  use "akinsho/toggleterm.nvim"

  -- LuaSnip
  use "L3MON4D3/LuaSnip" --snippet engine
  use "rafamadriz/friendly-snippets" -- a bunch of snippets to use

  -- Cmp
  use "hrsh7th/nvim-cmp" -- The completion plugin
  use "hrsh7th/cmp-buffer" -- buffer completions
  use "hrsh7th/cmp-path" -- path completions
  use "hrsh7th/cmp-cmdline" -- cmdline completions
  use "hrsh7th/cmp-nvim-lsp"
  use "saadparwaiz1/cmp_luasnip" -- snippet completions

  use { "mattn/emmet-vim" }

  -- Search and Replace
  use {
    "windwp/nvim-spectre",
    event = "BufRead",
    config = function()
      require("spectre").setup()
    end,
  }

  -- Git
  use "lewis6991/gitsigns.nvim"

  if packer_bootstrap then
    require('packer').sync()
  end
end)
