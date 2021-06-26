filetype plugin indent on
au BufRead,BufNewFile *.md  set filetype=markdown
syntax enable

packloadall
" let g:pathogen_disabled = ["autoclose"]
execute pathogen#infect()

" Styling

if (has("termguicolors"))
    set termguicolors
endif

set background=dark
let g:palenight_color_overrides = {
            \'black': { "gui": "#180920", "cterm": "54", "cterm16": "0"}
            \}
let g:palenight_terminal_italics=1
colorscheme palenight
let g:airline_theme='palenight'
let g:promptline_theme = 'airline'

let g:airline_powerline_fonts = 1
let g:promptline_preset = {
        \'a': [ '$(date +%H:%M:%S)'],
        \'b': [ promptline#slices#user() ],
        \'c': [ promptline#slices#cwd() ],
        \'x': [promptline#slices#python_virtualenv()],
        \'y' : [ promptline#slices#vcs_branch(), promptline#slices#jobs() ],
        \'warn' : [ promptline#slices#last_exit_code() ]}

" autocmd FileType markdown set spell
set expandtab
set tabstop=4
set shiftwidth=4
set number
set relativenumber " do numbering relative to current line
set cursorline
set laststatus=2
set encoding=utf-8
set autowrite

let g:calendar_google_calendar = 1
let g:calendar_google_task = 1

let g:vimwiki_list = [{'path': '~/sync/notes/', 'path_html': '~/sync/notes_html'}]

" Syntastic options
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

let g:tex_flavor='latex'

let g:ycm_rust_src_path = "/opt/rust/src"

if exists("loaded_less")
" put something in the powerline!
endif
