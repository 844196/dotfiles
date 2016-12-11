if exists('b:current_syntax')
    finish
endif

" 1行目のみ色をつける
syntax match quickrun_Sqloutput_Columns '\%^.*'
highlight link quickrun_Sqloutput_Columns CursorLineNr

let b:current_syntax = 'sqloutput'
