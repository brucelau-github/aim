if !executable('ollama')
	echoerr "ollama is required for aim plugin"
	finish
endif

let s:plugin_root = expand('<sfile>:p:h:h')

command! -range Aask <line1>,<line2>call aim#Ask('')
command! -range Arewrite <line1>,<line2>call aim#Ask('rewrite the following content in a profession tone, correct grammars and typos\n')
command! -range Aenrich <line1>,<line2>call aim#Ask('rewrite and expand the following content in a profession tone, correct grammars and typos if needed\n')

"Atalk 'correct the sentence'
command! -range -nargs=1 Atalk <line1>,<line2>call aim#Ask(<args>)

"auto complete comamnd
autocmd FileType * setlocal completefunc=aim#AutoPopupComplete
imap <C-j> <C-x><C-u>
