let b:pretty_view = 0
let b:new_file = 1

function! CountDelim(delim)
    "count the number of tabs in the file
    redir => cnt
        "silent exe "1s/\t//gn"
        silent exe "1s/" . a:delim . "//gn"
    redir END
    let first_space = stridx(cnt, " ")
    let num_tabs = str2nr(strpart(cnt, 1, first_space))
    return num_tabs
endfunction

function! GetColLengthList(delim)
    "find length of longest entry in each column
    let num_delim = CountDelim(a:delim)
    let largest_col_entries = map(range(num_delim+1), 0)

    "iterate through each line to find largest entry in each column
    let i = 0
    while i < line('$')
        "split each line and get length of each column entry
        let j = 0
        let vals = split(getline(i), a:delim)
        let val_lengths = map(vals, 'len(v:val)')

        while j < len(vals)
            "if current word is longest, update list
            if val_lengths[j] > largest_col_entries[j]
                let largest_col_entries[j] = val_lengths[j]
            endif
            let j += 1
        endwhile

        let i += 1
    endwhile
    return largest_col_entries
endfunction

function! TogglePrettyView()
    "only want to calculate vartabstops first time
    if !exists("b:new_file")
        let b:new_file = 1
    endif
    if b:new_file
        let largest_col_entries = GetColLengthList("\t")
        let largest_col_entries = map(largest_col_entries, '4+v:val')
        let b:new_tab_stops = join(largest_col_entries, ',')
        let b:new_file = 0
    endif

    if !exists("b:pretty_view")
        let b:pretty_view = 1
    endif
    if b:pretty_view
        execute 'setlocal vartabstop='
        let b:pretty_view = 0
    else
        execute 'setlocal vartabstop=' . b:new_tab_stops
        let b:pretty_view = 1
    endif
endfunction

function! SplitDelimView(delim)
    "open a split buffer with pretty view
    let largest_col_entries = GetColLengthList(a:delim)
    let largest_col_entries = map(largest_col_entries, '4+v:val')
    let b:new_delim_stops = join(largest_col_entries, ',')
    let x = b:new_delim_stops

    normal! ggVG"py
    silent split PrettyView
    normal! "ppkdd
    silent exec "%s/" . a:delim . "/\t/g"
    normal! gg
    exec "setlocal vartabstop=" . x
    set ro

    setlocal bufhidden=hide
    setlocal noswapfile
    setlocal buftype=nowrite
endfunction

command! -nargs=0 TogglePrettyTabView call TogglePrettyView()
command! -nargs=1 SplitDelimView call SplitDelimView(<f-args>)
