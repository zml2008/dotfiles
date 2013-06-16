filetype plugin indent on
au BufRead,BufNewFile *.md  set filetype=markdown
syntax enable

execute pathogen#infect()

" autocmd FileType markdown set spell
set background=light
colorscheme solarized
set expandtab
set tabstop=4
set shiftwidth=4
set number
set laststatus=2
set encoding=utf-8

if exists("loaded_less")
" put something in the powerline!
endif
