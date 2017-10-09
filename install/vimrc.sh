git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime
sh ~/.vim_runtime/install_awesome_vimrc.sh

cat << EOF >> ~/.vimrc
set number

filetype plugin indent on
" show existing tab with 4 spaces width
set tabstop=4
" when indenting with '>', use 4 spaces width
set shiftwidth=4
" On pressing tab, insert 4 spaces
set expandtab

let g:NERDTreeWinPos = "left"
autocmd VimEnter * NERDTree
autocmd VimEnter * wincmd p
" Exit vim if NERDTree is the last buffer remaining
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif


EOF

echo Local overrides applied.
echo Vim setup complete.
