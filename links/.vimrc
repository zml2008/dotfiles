filetype plugin indent on
au BufRead,BufNewFile *.md  set filetype=markdown
syntax enable

" let g:pathogen_disabled = ["autoclose"]
execute pathogen#infect()
let g:airline_powerline_fonts = 1
let g:airline_theme='powerlineish'
let g:promptline_preset = {
        \'a': [ '$(date +%H:%M:%S)'],
        \'b': [promptline#slices#user() ],
        \'c': [ promptline#slices#cwd() ],
        \'y' : [ promptline#slices#vcs_branch() ],
        \'warn' : [ promptline#slices#last_exit_code() ]}
" autocmd FileType markdown set spell
set background=dark
set expandtab
set tabstop=4
set shiftwidth=4
set number
set laststatus=2
set encoding=utf-8

if exists("loaded_less")
" put something in the powerline!
endif
