"BASIC KEY MAPPINGS
"This is the interface for zettel creation.
nnoremap <leader>z :set operatorfunc=<SID>ZettelCreationHandler<cr>g@
vnoremap <leader>z :<c-u>call <SID>ZettelCreationHandler(visualmode())<cr>

"HTML CONVNIENCE MAPPINGS
nnoremap <leader>q :Vimwiki2HTML<cr>
nnoremap <leader>qa :VimwikiAll2HTML<cr>

"TAG CONVENIENCE MAPPINGS
nnoremap <leader>ws :VimwikiSearchTags 
nnoremap <leader>wrt :VimwikiRebuildTags<cr>
"Searches for the tag my cursor is currently on
nnoremap <leader>wft :VimwikiSearchTags <cWORD><cr> 

"Opens the current wiki's html counterpoart in a new firefox tab
nnoremap <leader>oh maggw"ayw:!firefox ~/vimwiki_html/<C-R>a<bs>.html &<cr>`a



"ABBERVIATIONS
iabbrev zett zettelkasten
iabbrev Zett Zettelkasten
iabbrev $$ {{$ <cr><cr>}}$



"FUNCTIONS
function! s:ZettelCreationHandler(type)
    "This is my interface for zet creation. Currently I only have visual
    "character mode implemented. I will eventually fill this out with more
    "detail and may even include more options
    let saved_unnamed_register = @@

    if a:type ==# 'v'
        normal! `<v`>d
    elseif a:type ==# 'char'
        return
    else
        return
    endif
    call s:CreateZettel(@@)

    let @@ = saved_unnamed_register
endfunction

"TODO: I need to break apart two types of changes. I want a function that
"creates a new zettel and a function that makes changes to the current file.
"Right now both of these sort of operations are being done together and I
"don't think that's ideal.
function! s:CreateZettel(title)
    let timestamp = s:MakeTimeStamp()
    let zettel_link = s:MakeZettelLink(timestamp, a:title)
    call s:InsertTextAtCurrentPosition(zettel_link)
    let zettel_text = s:MakeZettelText(timestamp, a:title)
    let file_name = timestamp . '.wiki'
    call system('echo ' . shellescape(zettel_text) .  ' >> ' . file_name)
endfunction

"Helper functions
function! s:MakeZettelLink(timestamp, title)
    "Input: 
    "   timestamp (str): The timestamp string corresponding to the zettel
    "   title (str): The title of the link created
    "Output:
    "   zettel_link (str): The text link corresponding to the timestamp and
    "   title
    return "[[" . a:timestamp . "|" . a:title . "]]"
endfunction

function! s:MakeZettelText(timestamp, title)
    "Input: 
    "   timestamp (str): The timestamp string corresponding to the zettel
    "   title (str): The title of the zettel being created
    "Output:
    "   zettel_text (str): The text of the zettel created from the timestamp
    "   and the title
    return a:title . "\n\n" . s:MakeZettelLink(a:timestamp, a:title) . "\n\n----"
endfunction

function! s:MakeTimeStamp()
    "Output:
    "   timestamp (str): The timestamp string corresponding to the present
    "   moment. The format is yyyymmddhhmmss
    return trim(strftime('%Y%m%d%H%M%S'))
endfunction

function! s:InsertTextAtCurrentPosition(text)
    "Input: 
    "   text (str): The text to be inserted at the current position
    "Output:
    "   result (int): 0 indicates successful insertion while 1 indicates
    "   unsuccesful insertion
    let line_n = line('.')
    let column_n = col('.')
    let string_index = column_n - 1
    let current_line = getline(line_n)
    if column_n == 1
        call setline(line('.'), a:text . current_line)
        return 0
    elseif column_n == strlen(current_line)
        call setline(line('.'), current_line . a:text)
        return 0
    else
        call setline(line('.'), current_line[:string_index - 1] . a:text . current_line[string_index:])
        return 0
    endif
    return 0
endfunction
