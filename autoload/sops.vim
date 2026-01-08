" File: autoload/sops.vim
" Description: Main logic for SOPS encryption/decryption

function! s:get_indent(line) abort
    return matchstr(a:line, '^\s*')
endfunction

function! sops#process(is_decrypt, line1, line2) abort
    let l:lines = getline(a:line1, a:line2)
    let l:content = join(l:lines, "\n")

    " 1. Prevention of duplicate processing
    let l:has_sops = l:content =~# 'sops:'
    if a:is_decrypt && !l:has_sops
        echo "Skip: Content is not encrypted with sops."
        return
    elseif !a:is_decrypt && l:has_sops
        echo "Skip: Content is already encrypted with sops."
        return
    endif

    " 2. Indent handling (for range selection)
    let l:min_indent = ""
    if a:line1 != a:line2
        let l:indents = map(copy(l:lines), 'len(s:get_indent(v:val))')
        let l:min_indent_len = min(l:indents)
        let l:min_indent = repeat(' ', l:min_indent_len)
        " Strip leading indentation before passing to sops
        let l:processed_lines = map(copy(l:lines), 'substitute(v:val, "^" . l:min_indent, "", "")')
        let l:content = join(l:processed_lines, "\n")
    endif

    " 3. Build and execute SOPS command
    let l:cmd = 'sops ' . (a:is_decrypt ? '--decrypt' : '--encrypt')
    let l:cmd .= ' --input-type yaml --output-type yaml'
    if !empty(g:sops_args)
        let l:cmd .= ' ' . g:sops_args
    endif
    let l:cmd .= ' /dev/stdin'

    let l:result = system(l:cmd, l:content)

    " Handle execution errors
    if v:shell_error != 0
        echoerr "SOPS Error: " . l:result
        return
    endif

    " 4. Restore indentation and apply to buffer
    let l:result_lines = split(l:result, "\n")
    if !empty(l:min_indent)
        call map(l:result_lines, 'l:min_indent . v:val')
    endif

    let l:old_line_count = a:line2 - a:line1 + 1
    let l:new_line_count = len(l:result_lines)
    let l:common_lines = min([l:old_line_count, l:new_line_count])

    " Update existing lines
    call setline(a:line1, l:result_lines[: l:common_lines - 1])

    if l:new_line_count > l:old_line_count
        " Append extra lines if result is longer
        call append(a:line1 + l:old_line_count - 1, l:result_lines[l:old_line_count :])
    elseif l:new_line_count < l:old_line_count
        " Delete trailing lines if result is shorter
        execute (a:line1 + l:new_line_count) . "," . a:line2 . "delete _"
    endif
endfunction
