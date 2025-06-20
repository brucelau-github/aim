let s:plugin_root = expand('<sfile>:p:h:h')

command! -range Aask call aim#Ask()
command! -range Arewrite call aim#Ask('rewrite the following content in a profession tone, correct grammars and typos\n')
command! -range Aenrich call aim#Ask('rewrite and expand the following content in a profession tone, correct grammars and typos if needed\n')

"Atalk 'correct the sentence'
command! -range -nargs=1 Atalk call aim#Ask(<args>)
