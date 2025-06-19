let s:plugin_root = expand('<sfile>:p:h:h')

command! -range=% Aimrewrite call aim#Rewrite()
