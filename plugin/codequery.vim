if !exists("g:codequeryprg")
    " let dbpath='D:\android\project\alps_f_base\frameworks\cqproject.db'
	" let g:cquery='cqsearch -s '.$CQDBPATH.' -c -e -p '
    let g:cquery='cqsearch '
endif

function! s:Cquery(cmd, args)
    if exists("g:cqdb")
        let g:cqdb = ""
    endif
    call FindCqueryDB()
    if !exists("g:cqdb") || len(g:cqdb)<=0
        echo "No db file found."
        return
    endif

    redraw
    echo "Searching ..."

    " If no pattern is provided, search for the word under the cursor
    if empty(a:args)
        let l:grepargs = expand("<cword>")
    else
        let l:grepargs = a:args
    end

    "把参数转为cmd的GBK编码，否则搜索不了中文；另一种方案是把quickfix搜索结果转为GBK编码
    let l:grepargs = iconv(l:grepargs, "utf-8", "cp936")

    let grepprg_bak=&grepprg
    let grepformat_bak=&grepformat
    try
        let &grepprg=g:cquery
        let &grepformat="%f:%l\t%m"
        echo g:cquery." ".l:grepargs
        silent execute a:cmd . " -s " .g:cqdb.' -c -e -p '. l:grepargs
    finally
        let &grepprg=grepprg_bak
        let &grepformat=grepformat_bak
    endtry

    " call QfMakeConv()

    if a:cmd =~# '^l'
        botright lopen
    else
        botright copen
    endif

    exec "nnoremap <silent> <buffer> q :ccl<CR>"
    exec "nnoremap <silent> <buffer> t <C-W><CR><C-W>T"
    exec "nnoremap <silent> <buffer> T <C-W><CR><C-W>TgT<C-W><C-W>"
    exec "nnoremap <silent> <buffer> o <CR>"
    exec "nnoremap <silent> <buffer> go <CR><C-W><C-W>"
    exec "nnoremap <silent> <buffer> v <C-W><C-W><C-W>v<C-L><C-W><C-J><CR>"
    exec "nnoremap <silent> <buffer> gv <C-W><C-W><C-W>v<C-L><C-W><C-J><CR><C-W><C-J>"

    " If highlighting is on, highlight the search keyword.
    if exists("g:csearchhighlight")
        let @/=a:args
        set hlsearch
    end

    redraw!
endfunction

function! s:CqueryFromSearch(cmd, args)
    let search =  getreg('/')
    " translate vim regular expression to perl regular expression.
    let search = substitute(search,'\(\\<\|\\>\)','\\b','g')
    call s:Cquery(a:cmd, '"' .  search .'" '. a:args)
endfunction

command! -bang -nargs=* -complete=file Cquery call s:Cquery('grep<bang>',<q-args>)
command! -bang -nargs=* -complete=file CqueryAdd call s:Cquery('grepadd<bang>', <q-args>)
command! -bang -nargs=* -complete=file CqueryFromSearch call s:CqueryFromSearch('grep<bang>', <q-args>)
command! -bang -nargs=* -complete=file LCquery call s:Cquery('lgrep<bang>', <q-args>)
command! -bang -nargs=* -complete=file LCqueryAdd call s:Cquery('lgrepadd<bang>', <q-args>)

nmap cqg :Cquery g -t <C-R>=expand("<cword>")<CR><CR>
nmap cqs :Cquery s -t <C-R>=expand("<cword>")<CR><CR>
nmap cqq :Cquery q -t <C-R>=expand("<cword>")<CR><CR>
nmap cqc :Cquery c -t <C-R>=expand("<cword>")<CR><CR>
nmap cqd :Cquery d -t <C-R>=expand("<cword>")<CR><CR>


function! QfMakeConv()
   let qflist = getqflist()
   for i in qflist
      " let i.text = iconv(i.text, "cp936", "utf-8")
      let i.text = iconv(i.text, "utf-8", "cp936")
   endfor
   call setqflist(qflist)
endfunction

function! FindCqueryDB()
    let dir=expand("%:p:h")
    " if exists("g:csindex") && len(dir)>=len(g:csindex)
        " return
    " endif

    let prefixPath="/.KingConfig"
    let csindexfilename="cqproject.db"
    let dirLen=len(dir)
    while (g:iswindows==1 && dirLen>3) || (g:iswindows!=1 && dirLen>1)
        if isdirectory(dir.prefixPath) && filereadable(dir.prefixPath."/".csindexfilename)
           let g:cqdb = dir.prefixPath."/".csindexfilename
           return 
        endif
        let dir=fnamemodify(dir, ':h')
        let dirLen=len(dir)
    endwhile
endfunction
