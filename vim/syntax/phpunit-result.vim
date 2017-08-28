if exists('b:current_syntax')
    finish
endif

syntax match PhpUnitOk '^OK.*'
highlight PhpUnitOk guibg=#8c9440 guifg=#282a2d

syntax region PhpUnitWarning start='^WARNINGS!' end='.*Warnings.*\.'
highlight PhpUnitWarning guibg=#de935f guifg=#282a2d

syntax region PhpUnitFailure start='^FAILURES!' end='.*Failures.*\.'
highlight PhpUnitFailure guibg=#a54242 guifg=#282a2d

syntax region PhpUnitError start='^ERRORS' end='.*Errors.*\.'
highlight PhpUnitError guibg=#a54242 guifg=#282a2d

let b:current_syntax = 'phpunit-result'
