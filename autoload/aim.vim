if !exists('g:aim_ollama_model')
	let g:aim_ollama_model = 'llama3.2'
endif

let s:ollama = 'COLOR=1 ollama run ' . g:aim_ollama_model
let s:separator = repeat('-', 40)
let s:completion_prompt = [
	\' Generate a list of 5 strings to help the user to complete the thought of the following pargraph or code or sentence in a natural and coherent way.',
	\' Format the list in JSON array.',
	\ ''
	\ ]

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

function! s:ollama_cmd(prompt) abort
	let l:tmpfile = s:save_temp_file(a:prompt)
	let l:outputfile = tempname()
	let l:ollama_cmd = s:ollama . ' < ' . shellescape(l:tmpfile)
	let l:ollama_cmd = l:ollama_cmd . ' > ' . l:outputfile

	call system(l:ollama_cmd)

	call s:delete_tmpfile(l:tmpfile)

	if filereadable(l:outputfile)
		let l:out_lines = readfile(l:outputfile)
		call s:delete_tmpfile(l:outputfile)
	else
		echoerr 'response file not found: ' . l:outputfile
	endif
	return l:out_lines
endfunction

function! s:ollama_rest(prompt) abort
	if empty(a:prompt)
		echoerr "Prompt is empty"
		return
	endif

	let l:prompt = a:prompt
	if type(a:prompt) == type([])
		let l:prompt = join(a:prompt, "\n")
	endif

	let l:url = 'http://localhost:11434/api/generate'

	let l:data = json_encode({
			\ 'model': g:aim_ollama_model,
			\ 'prompt': l:prompt,
			\ 'stream': v:false
			\ })

	let l:cmd = 'curl -s -X POST ' . shellescape(l:url) . ' -H "Content-Type: application/json" -d ' . shellescape(l:data)

	let l:result = system(l:cmd)

	" Parse response (assumes JSON with 'response' field)
	try
		let l:resp = json_decode(l:result)
		if has_key(l:resp, 'response')
			return split(l:resp.response, '\n')
		else
			echoerr "No response field in result"
		endif
	catch
		echoerr "Invalid JSON: " . l:result
	endtry
endfunction

function! s:parse_quoted_list(lines) abort
	let l:start_idx = -1
	let l:end_idx = -1

	" Locate the opening and closing brackets
	for l:i in range(len(a:lines))
		if a:lines[l:i] =~ '^\s*\['
		let l:start_idx = l:i + 1
		elseif a:lines[l:i] =~ '^\s*\]'
		let l:end_idx = l:i - 1
		break
		endif
	endfor

	" Guard clause for invalid structure
	if l:start_idx == -1 || l:end_idx == -1 || l:end_idx < l:start_idx
		echoerr "Could not find valid quoted list block."
		return []
	endif

	" Extract and clean the quoted lines
	let l:result = []
	for l:i in range(l:start_idx, l:end_idx)
		let l:line = a:lines[l:i]
		let l:cleaned = substitute(l:line, '^\s*"\(.*\)",\?\s*$', '\1', '')
		call add(l:result, l:cleaned)
	endfor

	return l:result
endfunction

function! aim#Ask(prompt) range abort
	let l:lines = getline(a:firstline, a:lastline)

	if empty(filter(copy(l:lines), 'v:val =~# "\\S"'))
		echoerr 'Error: Selected range is empty or only contains whitespace.'
		return
	endif

	let l:tmpfile = s:save_temp_file(l:lines)

	let l:wrapped_prompt = [a:prompt] + ['', ''] + l:lines
	let l:output = s:call_llm(l:wrapped_prompt)
	let l:wrapped_output = ['>>> Assistant ' . repeat('-', 26 )] + l:output + [s:separator]
	call append(a:lastline, l:wrapped_output)
endfunction

function! aim#AutoPopupComplete(findstart, base) abort
	if a:findstart
		return col('.') - 1
	else
		let l:start = max([1, line('.') - 300])
		let l:end = line('.') - 1
		let l:lines = getline(l:start, l:end)
		let l:wrapped = s:completion_prompt + ['---- start ' . s:separator] + l:lines + [ '---- end ' . s:separator]
		let l:output = s:call_llm(l:wrapped)
		return s:parse_quoted_list(l:output)
	endif
endfunction
