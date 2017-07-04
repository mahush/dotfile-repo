execute pathogen#infect()
syntax on
filetype plugin indent on
set number

"enable syntax formating for config files
au BufEnter,BufRead *.conf setf dosini

set shiftwidth=4 

" open diffs in vertical split view
set diffopt+=vertical
