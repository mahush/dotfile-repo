execute pathogen#infect()
syntax on
filetype plugin indent on
set number

"enable syntax formating for config files
au BufEnter,BufRead *.conf setf dosini

set shiftwidth=4 

syntax enable

:set hlsearch

" open diffs in vertical split view
set diffopt+=vertical

" enable relative line nubmers
set relativenumber

" show invisible chars
set listchars=eol:¬,tab:>-,trail:~,extends:>,precedes:<,space:·
set list
