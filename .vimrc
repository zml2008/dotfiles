filetype plugin indent on

if &t_Co > 1
    syntax enable
endif

execute pathogen#infect()

" autocmd FileType markdown set spell
set background=dark
colorscheme solarized
set expandtab
set tabstop=4
set shiftwidth=4

set laststatus=2
set encoding=utf-8

if exists("loaded_less")
" put something in the powerline!
endif
