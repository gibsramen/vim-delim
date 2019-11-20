function! CountTabs()
    "count the number of tabs in the file
    redir => cnt
        silent exe "1s/\t//gn"
    redir END
    let num_tabs = str2nr(strpart(cnt, 1, 1))
    return num_tabs
endfunction

function! GetColLengthList()
    "find length of longest entry in each column
    let num_tabs = CountTabs()
    let largest_col_entries = map(range(num_tabs+1), 0)

    "iterate through each line to find largest entry in each column
    let i = 0
    while i < line('$')
        "split each line and get length of each column entry
        let j = 0
        let vals = split(getline(i), '\t')
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
    if b:new_file
        let largest_col_entries = GetColLengthList()
        let largest_col_entries = map(largest_col_entries, '4+v:val')
        let b:new_tab_stops = join(largest_col_entries, ',')
        let b:new_file = 0
    endif

    if b:pretty_view
        execute 'setlocal vartabstop='
        let b:pretty_view = 0
    else
        execute 'setlocal vartabstop=' . b:new_tab_stops
        let b:pretty_view = 1
    endif
endfunction

let b:pretty_view = 0
let b:new_file = 1
nmap <leader>p :call TogglePrettyView()<CR>
