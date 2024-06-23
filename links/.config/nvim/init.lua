vim.cmd.filetype({'plugin', 'indent', 'on'})
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
    pattern = { "*.md" },
    callback = function()
        vim.o.filetype = 'markdown'
    end
})
vim.cmd.syntax('enable')

-- Setup plugin loading
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
    { "drewtempelmeyer/palenight.vim" },
    { "editorconfig/editorconfig-vim" },
    { "vim-airline/vim-airline" },
    { "vim-airline/vim-airline-themes" },
    { "edkolev/tmuxline.vim" },
    { "edkolev/promptline.vim" }
}, { performance = { rtp = { reset = false }}})

-- let g:pathogen_disabled = ["autoclose"]
vim.fn['pathogen#infect']()

-- Styling
if vim.fn.has("termguicolors") then
    vim.o.termguicolors = true
end

vim.o.background='dark'
vim.g.palenight_color_overrides = {
    black = { gui = "#180920", cterm = "54", cterm16 = "0" }
}

vim.g.palenight_terminal_italics=1
vim.cmd.colorscheme('palenight')
vim.g.airline_theme = 'palenight'
vim.g.promptline_theme = 'airline'

vim.g.airline_powerline_fonts = 1
vim.g.promptline_preset = {
    a = { '$(date +%H:%M:%S)'},
    b = { vim.fn['promptline#slices#user']() },
    c = { vim.fn['promptline#slices#cwd']() },
    x = { vim.fn['promptline#slices#python_virtualenv']() },
    y = { vim.fn['promptline#slices#vcs_branch'](), vim.fn['promptline#slices#jobs']() },
    warn = { vim.fn['promptline#slices#last_exit_code']() }
}


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

-- Start interactive EasyAlign in visual mode (e.g. vipga)
vim.keymap.set({"x"}, "ga", "<Plug>(EasyAlign)")

-- Start interactive EasyAlign for a motion/text object (e.g. gaip)
vim.keymap.set({"n"}, "ga", "<Plug>(EasyAlign)")

vim.g.tex_flavor = 'latex'
vim.g.ycm_rust_src_path = "/opt/rust/src"
