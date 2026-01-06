" vim fallback config for when nvim is not/cannot be used
" bits yoinked from @bahamas10, i like his stuff
" ===================================
" minimal vim config just in case
" ===================================
set nocompatible

" ===================================
" options
" ===================================
set autoindent			        " Default to indenting files
set backspace=indent,eol,start	" Backspace all characters
set formatoptions-=t		    " Don't add line-breaks for lines over 'textwidth' characters
set hlsearch			        " Highlight search results
set nonumber			        " Disable line numbers
set nostartofline		        " Do not jump to first character with page commands
set ruler			            " Enable the ruler
set showmatch			        " Show matching brackets.
set showmode			        " Show the current mode in status line
set showcmd			            " Show partial command in status line
set tabstop=2			        " Number of spaces <tab> counts for
set textwidth=80		        " 80 columns
set title			            " Set the title

" ===================================
" themes
" ===================================
set background=dark            
hi Comment ctermfg=63		    " Brighten up comment colors

" ===================================
" abbreviations
" ===================================
iab <expr> me:: strftime("Author: Devon Casey <me@devoncasey.com><cr>Date: %B %d, %Y<cr>License: MIT")

" ===================================
" no whitespace
" ===================================
highlight RedundantWhitespace ctermbg=green guibg=green
match RedundantWhitespace /\s\+$\| \+\ze\t/

" ===================================
" spell check
" ===================================
set spelllang=en
highlight clear SpellBad
highlight SpellBad term=standout cterm=underline ctermfg=red
highlight clear SpellCap
highlight SpellCap term=underline cterm=underline
highlight clear SpellRare
highlight SpellRare term=underline cterm=underline
highlight clear SpellLocal
highlight SpellLocal term=underline cterm=underline

" ===================================
" local overwrites
" ===================================
if filereadable(expand("~/.vimrc.local"))
	source ~/.vimrc.local
endif
if filereadable(expand("~/.vimrc.indent"))
	source ~/.vimrc.indent
endif
