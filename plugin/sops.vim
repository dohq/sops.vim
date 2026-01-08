" File: plugin/sops.vim
" Description: Entry point for vim-sops-simple
" Maintainer: dohq

if exists('g:loaded_vim_sops_simple') | finish | endif
let g:loaded_vim_sops_simple = 1

" Default configuration
let g:sops_args = get(g:, 'sops_args', '')

" Command definitions
" Triggers autoload/sops.vim on first execution
command! -range=% SopsEncrypt call sops#process(0, <line1>, <line2>)
command! -range=% SopsDecrypt call sops#process(1, <line1>, <line2>)

" Default mappings (only if not already mapped)
if !hasmapto('<Plug>SopsEncrypt') && maparg('<Leader>se', 'n') ==# ''
    nmap <unique> <Leader>se :SopsEncrypt<CR>
endif
if !hasmapto('<Plug>SopsDecrypt') && maparg('<Leader>sd', 'n') ==# ''
    nmap <unique> <Leader>sd :SopsDecrypt<CR>
endif
