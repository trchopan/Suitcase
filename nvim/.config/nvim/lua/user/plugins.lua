local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
    packer_bootstrap = fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim',
        install_path })
    vim.cmd [[packadd packer.nvim]]
end

return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'

    use({
        "iamcco/markdown-preview.nvim",
        run = "cd app && npm install",
        setup = function() vim.g.mkdp_filetypes = { "markdown" } end,
        ft = { "markdown" },
    })

    use({
      "jackMort/ChatGPT.nvim",
        requires = {
          "MunifTanjim/nui.nvim",
          "nvim-lua/plenary.nvim",
          "nvim-telescope/telescope.nvim"
        }
    })

    -- Themes
    use 'folke/tokyonight.nvim'
    use { "catppuccin/nvim", as = "catppuccin" }
    use 'navarasu/onedark.nvim'
    use "savq/melange"

    use 'kyazdani42/nvim-web-devicons'
    use 'kyazdani42/nvim-tree.lua'
    use 'romgrk/barbar.nvim'
    use 'nvim-lualine/lualine.nvim'
    use 'rmagatti/auto-session'

    use 'nvim-lua/plenary.nvim'    -- Useful lua functions used by lots of plugins
    use "lewis6991/impatient.nvim" -- Speed up loading Lua modules in Neovim to improve startup time.

    use 'tpope/vim-surround'
    use 'tpope/vim-abolish' -- Search replace with case and plural aware. Also support for case coercion.
    use "phaazon/hop.nvim"
    use 'mfussenegger/nvim-treehopper' -- Use Treesitter to hop arround
    use 'booperlv/nvim-gomove'
    use "windwp/nvim-autopairs"
    use 'lfv89/vim-interestingwords'

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
            vim.o.timeout = true
            vim.o.timeoutlen = 300
            require("which-key").setup {}
        end,
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
    use "neovim/nvim-lspconfig"             -- enable LSP
    use "williamboman/mason.nvim"           -- simple to use language server installer
    use "williamboman/mason-lspconfig.nvim" -- helper for mason and lspconfig
    use "tamago324/nlsp-settings.nvim"      -- language server settings defined in json for
    use "jose-elias-alvarez/null-ls.nvim"   -- inject LSP diagnostics, code actions, and more
    use "folke/trouble.nvim"
    use "akinsho/toggleterm.nvim"

    -- Flutter
    use {
        'akinsho/flutter-tools.nvim',
        requires = {
            'nvim-lua/plenary.nvim',
            -- 'stevearc/dressing.nvim', -- optional for vim.ui.select
        },
    }

    -- LuaSnip
    use "L3MON4D3/LuaSnip"             --snippet engine
    use "rafamadriz/friendly-snippets" -- a bunch of snippets to use

    -- Cmp
    use "hrsh7th/nvim-cmp"         -- The completion plugin
    use "hrsh7th/cmp-buffer"       -- buffer completions
    use "hrsh7th/cmp-path"         -- path completions
    use "hrsh7th/cmp-cmdline"      -- cmdline completions
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
