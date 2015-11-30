
" assumes (at least) +0 in cinoptions
function! CppIndentFunc()
    let l:cline_num = line('.')
    let l:cline = getline(l:cline_num)

    let l:pline_num = prevnonblank(l:cline_num - 1)
    let l:pline = getline(l:pline_num)
    "while l:pline =~# '\(^\s*{\s*\|^\s*//\|^\s*/\*\|\*/\s*$\)'
    while l:pline =~# '\(^\s*//\|^\s*/\*\|\*/\s*$\)'
        let l:pline_num = prevnonblank(l:pline_num - 1)
        let l:pline = getline(l:pline_num)
    endwhile

    let l:ppline_num = prevnonblank(l:pline_num - 1)
    let l:ppline = getline(l:ppline_num)
    "while l:ppline =~# '\(^\s*{\s*\|^\s*//\|^\s*/\*\|\*/\s*$\)'
    while l:ppline =~# '\(^\s*//\|^\s*/\*\|\*/\s*$\)'
        let l:ppline_num = prevnonblank(l:ppline_num - 1)
        let l:ppline = getline(l:ppline_num)
    endwhile

    let l:retv = cindent('.')
    let l:pindent = indent(l:pline_num)
    let l:opening_ab_matches = len(split(l:pline, '<', 1)) - 1
    let l:closing_ab_matches = len(split(l:pline, '>', 1)) - 1

    let l:opening_paren_matches = len(split(l:pline, '(', 1)) - 1
    let l:closing_paren_matches = len(split(l:pline, ')', 1)) - 1

    echom l:ppline_num l:pline_num l:cline_num

    let l:matchindent = 1 " like m1 m0 in cino

    if l:cline =~# '^\s*namespace.*'
        let l:retv = 0
        echom "echo0"
    elseif l:pline =~# '^\s*namespace.*{$' "if pline ends with ; or ( we leave to cindent  
        let l:retv = 0
    elseif l:ppline =~# '^\s*namespace.*$' && l:pline =~# '^\s*{\s*$' "if pline ends with ; or ( we leave to cindent  
        let l:retv = 0
    " elseif l:pline =~# '^\s*template\s*\s*$'
    " elseif l:pline =~# '^\s*template.*>\s*$'
    "     let l:retv = l:pindent
    "     echom "echo1"
    " elseif l:pline =~# '^\s*typename\s*.*,\s*$' 
    "     let l:retv = l:pindent
    "     echom "echo2"
    " elseif l:pline =~# '^\s*typename\s*.*>\s*$'  
    "     echom "echo3"
    "     let l:retv = l:pindent - &shiftwidth
    elseif l:pline =~# '^.*[;(]\s*$' "if pline ends with ; or ( we leave to cindent  
        echom "echo4"
        let l:retv = l:retv " do nothing
    " elseif l:pline =~# '^.*>.*(\s*$'  " >anything( on previous line
    "     echom "echo5"
    "     let l:retv = l:pindent + &shiftwidth
    elseif l:cline =~# '^\(\s*).*$' "cline starting with ) we leave to cindent  
        echom "echo6"
        let l:retv = l:retv " do nothing
    elseif l:pline =~# '^\s*typedef.*[^;]\s*$' "pline with typedef not ending with ;
        echom "echo7"
        let l:retv = l:pindent + &shiftwidth
    elseif l:pline =~# '^\s*>\s*$' "pline with a single >
        if l:matchindent==1
            echom "echo8"
            let l:retv = l:pindent - &shiftwidth
        else
            echom "echo9"
            let l:retv = l:pindent
        endif
    elseif !(l:opening_ab_matches == l:closing_ab_matches) "unbalances angle brackets
        " theres an unbalanced opening paren in pline, We want to use cindents value for cases where 1st arg is on the line of the paren, 
        " and where the second should arg be aligned with it
        if l:opening_paren_matches > l:closing_paren_matches 
            if l:opening_ab_matches > l:closing_ab_matches " unmatched opening bracket (presumably after the opening paren)
                echom "echo11"
                let l:retv = l:retv + &shiftwidth * (l:opening_ab_matches - l:closing_ab_matches) " add to indent specified by cindent
            else " mostlikely an extra closing angle > bracket before the paren, use cindent
                echom "echo12"
                let l:retv = l:retv
            endif
        else
            echom "echo13"
            let l:retv = l:pindent + &shiftwidth * (l:opening_ab_matches - l:closing_ab_matches) " work from indent of pline
        endif
    elseif l:pline =~# '^\s*::.*$' "pline starting with :: (like a single ::type)
        " theres an unbalanced opening paren in pline, We want to use cindents value for cases where 1st arg is on the line of the paren, 
        " and where the second should arg be aligned with it
        if l:opening_paren_matches > l:closing_paren_matches 
            let l:retv = l:retv " use cindent
        elseif l:matchindent==1
            echom "echo14"
            let l:retv = l:pindent 
        else
            echom "echo15"
            let l:retv = l:pindent - &shiftwidth
        endif
    elseif l:cline =~# '^\s*>.*$' "cline starting with a >
        if l:matchindent==1
            echom "echo16"
            let l:retv = l:pindent - &shiftwidth
        else
            echom "echo17"
            let l:retv = l:pindent 
        endif
    "elseif l:cline =~# '^\s*[>\.]\|\(::\).*$' "cline starting with a either of > . ::
    elseif l:cline =~# '^\s*::.*$' "cline starting with a either of . or ::
        if l:matchindent==1
            echom "echo18"
            let l:retv = l:pindent 
        else
            echom "echo19"
            let l:retv = l:pindent + &shiftwidth
        endif
    elseif l:ppline =~# '^.*<\s*$' " ppline ends with <
        " handle weird bug on second line of spread template arguments, vim
        " deindents the line when cino has +0
        if l:pline =~# '^.*,\s*$' " pline ends with ,
            let l:retv = l:pindent
            echom "echo20"
        else
            echom "echo21"
        endif
    elseif l:cline =~# '^\s*=.*$' " line starts with equal: indent (also when cino has +0)
        " handle weird bug on second line of spread template arguments, vim
        " deindents the line when cino has +0
        let l:retv = l:pindent + &shiftwidth
        echom "echo22"
    else
        echom "nomatch"
    endif
    echom l:retv
    return l:retv
endfunction

autocmd BufEnter *.{cc,cxx,cpp,h,hh,hpp,hxx,H,C} setlocal indentexpr=CppIndentFunc()

" indentkeys replaces cinkeys when using indentexpr (and lacking 0) by default in comparison)
set indentkeys+=0)
set indentkeys+=0>
set indentkeys+=0=
set indentkeys+=0=::
set cinoptions+=+0


