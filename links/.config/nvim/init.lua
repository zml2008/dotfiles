vim.cmd.filetype({'plugin', 'indent', 'on'})
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
    pattern = { "*.md" },
    callback = function()
        vim.o.filetype = 'markdown'
    end
})
-- vim.cmd.syntax('enable')

-- Styling
if vim.fn.has("termguicolors") then
    vim.o.termguicolors = true
end

-- autocmd FileType markdown set spell
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.number = true
vim.o.relativenumber = true -- do numbering relative to current line
vim.o.cursorline = true
vim.o.laststatus = 2
vim.o.encoding = 'utf-8'
vim.o.autowrite = true

-- Setup plugin loading
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    { "hrsh7th/cmp-nvim-lsp" },
    {
        "L3MON4D3/LuaSnip",
        build = "make install_jsregexp"
    },
    { "saadparwaiz1/cmp_luasnip"},
    {
        "hrsh7th/nvim-cmp",
        config = function()
            local luasnip = require 'luasnip'
            local cmp = require 'cmp'
            cmp.setup {
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end
                },
                mapping = cmp.mapping.preset.insert({
                    ['<C-u>'] = cmp.mapping.scroll_docs(-4), -- Up
                    ['<C-d>'] = cmp.mapping.scroll_docs(4), -- Down
                    -- C-b (back) C-f (forward) for snippet placeholder navigation.
                    ['<C-Space>'] = cmp.mapping.complete(),
                    ['<CR>'] = cmp.mapping.confirm {
                        behavior = cmp.ConfirmBehavior.Replace,
                        select = true,
                    },
                    ['<Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                    ['<S-Tab>'] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                }),
                sources = {
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "lazydev", group_index = 0 }
                }
            }
            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = 'path' }
                }, {
                    { name = 'cmdline' }
                })
            })
        end
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require 'nvim-treesitter.configs'.setup {
                ensure_installed = { "c", "lua", "vim", "vimdoc", "markdown", "markdown_inline",
                                     "bash", "toml", "json", "json5", "jsonc", "yaml", "xml", "python",
                                     "kotlin", "java", "latex", "groovy",
                                     "typescript", "css", "html",
                                     "r", "d", "nix", "git_config", "git_rebase"
                                 },
                highlight = { enable = true },
                indent = { enable = true }
            }
        end
    },
    { url = "https://gitlab.com/HiPhish/rainbow-delimiters.nvim.git"},
    {
        "neovim/nvim-lspconfig",
        config = function()
            local lspconfig = require'lspconfig'
            local capabilities = require("cmp_nvim_lsp").default_capabilities()
            local plain_servers = {
                'bashls',
                'clangd',
                'esbonio',
                'gradle_ls',
                'jdtls',
                'jsonls',
                'marksman',
                'texlab',
                'ltex',
                'lua_ls',
                'pkgbuild_language_server',
                'r_language_server',
                'yamlls'
            }
            for _, lsp in ipairs(plain_servers) do
                lspconfig[lsp].setup { capabilities = capabilities }
            end
        end
    },
    {
        "folke/lazydev.nvim",
        ft = "lua", -- only load on lua files
        opts = {
            library = {
                -- See the configuration section for more details
                -- Load luvit types when the `vim.uv` word is found
                { path = "luvit-meta/library", words = { "vim%.uv" } },
            },
        },
    },
    { "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
    { "editorconfig/editorconfig-vim" },
    { "lewis6991/gitsigns.nvim", config = function()
          require('gitsigns').setup()
      end
    },
    {
        "junegunn/vim-easy-align",
        keys = {
            -- Start interactive EasyAlign in visual mode (e.g. vipga)
            -- Start interactive EasyAlign for a motion/text object (e.g. gaip)
            {"ga", "<Plug>(EasyAlign)", mode = {"x", "n"}},
        }
    },
    { "udalov/kotlin-vim" },
    -- appearence
    {
        "drewtempelmeyer/palenight.vim",
        lazy = false,
        priority = 1000,
        config = function()
            vim.o.background='dark'
            vim.g.palenight_color_overrides = {
                black = { gui = "#180920", cterm = "54", cterm16 = "0" }
            }

            vim.g.palenight_terminal_italics=1
            vim.cmd.colorscheme('palenight')
        end
    },
    {
        "vim-airline/vim-airline",
        dependencies = { "vim-airline/vim-airline-themes" },
        config = function()
            vim.g.airline_theme = 'palenight'
            vim.g.airline_powerline_fonts = 1
        end
    },
    { "edkolev/tmuxline.vim" },
    {
        "edkolev/promptline.vim",
        config = function()
            vim.g.promptline_theme = 'airline'
            vim.g.promptline_preset = {
                a = { '$(date +%H:%M:%S)'},
                b = { vim.fn['promptline#slices#user']() },
                c = { vim.fn['promptline#slices#cwd']() },
                x = { vim.fn['promptline#slices#python_virtualenv']() },
                y = { vim.fn['promptline#slices#vcs_branch'](), vim.fn['promptline#slices#jobs']() },
                warn = { vim.fn['promptline#slices#last_exit_code']() }
            }
        end
    },
    { "tpope/vim-afterimage" },
    { "tpope/vim-eunuch" },
    { dir = vim.fn.stdpath("config") .. "/plugins/autoclose" }
}, {
})

if vim.g.loaded_less ~= nil then
-- put something in the powerline!
end

vim.g.tex_flavor = 'latex'
