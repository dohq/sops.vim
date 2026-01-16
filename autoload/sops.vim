" File: autoload/sops.vim
" Description: Core logic with shell-safe argument handling and config priority

function! s:get_indent(line) abort
    return matchstr(a:line, '^\s*')
endfunction

function! sops#process(is_decrypt, line1, line2, ...) abort
    let l:lines = getline(a:line1, a:line2)
    let l:content = join(l:lines, "\n")

    " Clean up the optional regex argument (strip surrounding quotes if any)
    let l:optional_regex = a:0 > 0 ? substitute(a:1, '^["'']\(.*\s*\)["'']$', '\1', '') : ''

    " 1. Prevention of duplicate processing
    let l:has_sops = l:content =~# 'sops:'
    if a:is_decrypt && !l:has_sops
        echo "Skip: Content is not encrypted."
        return
    elseif !a:is_decrypt && l:has_sops
        echo "Skip: Already encrypted."
        return
    endif

    " 2. Indentation handling
    let l:min_indent = ""
    if a:line1 != a:line2
        let l:indents = map(copy(l:lines), 'len(s:get_indent(v:val))')
        let l:min_indent_len = min(l:indents)
        let l:min_indent = repeat(' ', l:min_indent_len)
        let l:processed_lines = map(copy(l:lines), 'substitute(v:val, "^" . l:min_indent, "", "")')
        let l:content = join(l:processed_lines, "\n")
    endif

    " 3. Build SOPS command
    let l:cmd = 'sops ' . (a:is_decrypt ? '--decrypt' : '--encrypt')
    let l:cmd .= ' --input-type yaml --output-type yaml'

    let l:has_config_file = !empty(findfile('.sops.yaml', '.;'))

    if !a:is_decrypt
        if l:has_config_file
            " Case 1: .sops.yaml exists. Use it and optionally add --encrypted-regex
            if !empty(l:optional_regex)
                let l:cmd .= ' --encrypted-regex ' . shellescape(l:optional_regex)
            endif
        else
            " Case 2: No .sops.yaml. Use g:sops_args and apply optional regex override
            let l:base_args = g:sops_args
            if !empty(l:optional_regex)
                if l:base_args =~# '--encrypted-regex'
                    " Replace existing regex in the string
                    let l:base_args = substitute(l:base_args, '--encrypted-regex\s\+["''][^"'']*["'']', '--encrypted-regex ' . shellescape(l:optional_regex), 'g')
                    let l:base_args = substitute(l:base_args, '--encrypted-regex\s\+\S\+', '--encrypted-regex ' . shellescape(l:optional_regex), 'g')
                else
                    let l:base_args .= ' --encrypted-regex ' . shellescape(l:optional_regex)
                endif
            endif
            let l:cmd .= ' ' . l:base_args
        endif
    endif

    let l:cmd .= ' /dev/stdin'

    " 4. Execute
    let l:result = system(l:cmd, l:content)
    if v:shell_error != 0
        echoerr "SOPS Error: " . l:result
        return
    endif

    " 5. Reflect changes
    let l:result_lines = split(l:result, "\n")
    if !empty(l:min_indent)
        call map(l:result_lines, 'l:min_indent . v:val')
    endif

    let l:old_line_count = a:line2 - a:line1 + 1
    let l:new_line_count = len(l:result_lines)
    let l:common_lines = min([l:old_line_count, l:new_line_count])

    call setline(a:line1, l:result_lines[: l:common_lines - 1])
    if l:new_line_count > l:old_line_count
        call append(a:line1 + l:old_line_count - 1, l:result_lines[l:old_line_count :])
    elseif l:new_line_count < l:old_line_count
        execute (a:line1 + l:new_line_count) . "," . a:line2 . "delete _"
    endif
endfunction
