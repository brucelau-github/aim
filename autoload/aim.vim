let s:ollama = 'COLOR=1 ollama run llama3.2:latest'
let s:system = 'output format: text.'

function! s:clean_output(output)
	let l:ansi_escape_stripped = substitute(a:output, '\e\[[0-9;?]*[a-zA-Z]', '', 'g')
	let l:clean = substitute(l:ansi_escape_stripped,  '[^[:print:]\r\n\t]', '', 'g')
	let l:space_trimmed = trim(l:clean)
	return l:space_trimmed
endfunction

function! s:save_temp_file(lines)
	let l:tmpfile = tempname()
	call writefile(a:lines, l:tmpfile)
	return l:tmpfile
endfunction

function! s:delete_tmpfile(path)
  if filereadable(a:path)
    call delete(a:path)
  endif
endfunction

function! aim#Rewrite() range abort
	let l:lines = getline(a:firstline, a:lastline)
	let l:tmpfile = s:save_temp_file(l:lines)
	let l:outputfile = tempname()
	let l:ollama_cmd = s:ollama . ' "' . s:system . '" < ' . shellescape(l:tmpfile)
	let l:ollama_cmd = l:ollama_cmd . ' > ' . l:outputfile

	let l:raw = system(l:ollama_cmd)
	let l:clean = s:clean_output(l:raw)

	if filereadable(l:outputfile)
		let l:out_lines = readfile(l:outputfile)
		call append(line('.'), l:out_lines)
	else
		echoerr 'response file not found: ' . l:outputfile
	endif

	call s:delete_tmpfile(l:tmpfile)
	call s:delete_tmpfile(l:outputfile)
endfunction

