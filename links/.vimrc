filetype plugin indent on
au BufRead,BufNewFile *.md  set filetype=markdown
syntax enable

set background=dark
let base16colorspace=256
let theme = system('base16-template-for vim vim')
execute "source " . theme
let g:airline_theme='base16'
let g:promptline_theme = 'airline'


" let g:pathogen_disabled = ["autoclose"]
execute pathogen#infect()
let g:airline_powerline_fonts = 1
let g:promptline_preset = {
        \'a': [ '$(date +%H:%M:%S)'],
        \'b': [promptline#slices#user() ],
        \'c': [ promptline#slices#cwd() ],
        \'y' : [ promptline#slices#vcs_branch() ],
        \'warn' : [ promptline#slices#last_exit_code() ]}
" autocmd FileType markdown set spell
set expandtab
set tabstop=4
set shiftwidth=4
set number
set cursorline
set laststatus=2
set encoding=utf-8
set autowrite

let g:calendar_google_calendar = 1
let g:calendar_google_task = 1

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

if exists("loaded_less")
" put something in the powerline!
endif
