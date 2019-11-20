function! CountTabs()
    redir => cnt
        silent exe "1s/\t//gn"
    redir END
    let num_tabs = str2nr(strpart(cnt, 1, 1))
    return num_tabs
endfunction

function! GetTabLengthList()
    let num_tabs = CountTabs()
    let largest_col_entries = map(range(num_tabs+1), 0)
    let i = 1

    "iterate through each line to find largest entry in each column
    while i < line('$')
        let i += 1

        "split each line and get length of each column entry
        let j = 0
        let vals = split(getline(i))
        while j < len(vals)
            "if current word is longest, update list
            if len(vals[j]) > largest_col_entries[j]
                let largest_col_entries[j] = len(vals[j])
            endif
            let j += 1
        endwhile
    endwhile
    echo largest_col_entries
endfunction

nmap <leader>q :call GetTabLengthList()<CR>
