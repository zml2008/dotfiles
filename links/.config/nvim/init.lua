vim.cmd.filetype({'plugin', 'indent', 'on'})
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
    pattern = { "*.md" },
    callback = function()
        vim.o.filetype = 'markdown'
    end
})
vim.cmd.syntax('enable')

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
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
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
    performance = { rtp = { reset = false }}
})

-- let g:pathogen_disabled = ["autoclose"]
vim.fn['pathogen#infect']()

vim.g.calendar_google_calendar = 1
vim.g.calendar_google_task = 1

vim.g.vimwiki_list = {{path = '~/sync/notes/', path_html = '~/sync/notes_html'}}

-- Syntastic options
vim.g.syntastic_always_populate_loc_list = 1
vim.g.syntastic_auto_loc_list = 1
vim.g.syntastic_check_on_open = 1
vim.g.syntastic_check_on_wq = 0

if vim.g.loaded_less ~= nil then
-- put something in the powerline!
end

vim.g.tex_flavor = 'latex'
vim.g.ycm_rust_src_path = "/opt/rust/src"
