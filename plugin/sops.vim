" File: plugin/sops.vim
" Description: Entry point for vim-sops-simple
" Maintainer: dohq

if exists('g:loaded_vim_sops_simple') | finish | endif
let g:loaded_vim_sops_simple = 1

" Default arguments
let g:sops_args = get(g:, 'sops_args', '')

" Command Definitions
" Add -nargs=? argments to the SopsEncrypt commands
command! -range=% -nargs=? SopsEncrypt call sops#process(0, <line1>, <line2>, <q-args>)
command! -range=% SopsDecrypt call sops#process(1, <line1>, <line2>)

if !hasmapto('<Plug>SopsEncrypt') && maparg('<Leader>se', 'n') ==# ''
    nmap <unique> <Leader>se :SopsEncrypt<CR>
endif
if !hasmapto('<Plug>SopsDecrypt') && maparg('<Leader>sd', 'n') ==# ''
    nmap <unique> <Leader>sd :SopsDecrypt<CR>
endif
