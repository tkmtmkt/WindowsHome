" Vim syntax file
" Language:	CMS-2
" Maintainer:	Takamatsu Makoto <tkmtmkt@gmail.com>
" Url:		-

" Compatible VIM syntax file start
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" PowerShell doesn't care about case
syn case ignore

" Sync-ing method
syn sync minlines=100

syn match cs2Comment /^.\{,10}/

" Comments and special comment words
syn keyword cs2CommentTodo TODO FIXME XXX TBD HACK contained
syn region cs2Comment start=/''/ end=/''/ contains=cs2CommentTodo

" Language keywords and elements
syn keyword cs2Conditional if else elseif switch
syn keyword cs2Repeat while default for do until break continue
syn match cs2Repeat /\<foreach\>/ nextgroup=cs2Cmdlet
syn keyword cs2Keyword return filter in trap throw param begin process end
syn match cs2Keyword /\<while\>/ nextgroup=cs2Cmdlet

syn match cs2Keyword /(EXTDEF)/

syn match	cs2SystemName /\(\_^.\{10}\)\@=\w\+\>/ skipwhite nextgroup=cs2System
syn keyword	cs2System SYSTEM contained

syn keyword cs2Keyword SYS-PROC END-SYS-PROC
syn keyword cs2Keyword HEAD END-HEAD

" Functions and Cmdlets
syn keyword cs2Keyword FUNCTION nextgroup=cs2Function skipwhite
syn match cs2Function /\w\+/ contained

syn keyword cs2Keyword PROCEDURE nextgroup=cs2Function skipwhite
syn match cs2Function /\w\+/ contained

" Type declarations
syn match cs2Type /\[[a-z0-9_:.]\+\(\[\]\)\?\]/
syn match cs2StandaloneType /[a-z0-9_.]\+/ contained
syn keyword cs2Scope global local private script contained

" Variables and other user defined items
syn match cs2Variable /\$\w\+/	
syn match cs2Variable /\${\w\+:\\\w\+}/ 
syn match cs2ScopedVariable /\$\w\+:\w\+/ contains=cs2Scope
syn match cs2VariableName /\w\+/ contained

" Operators all start w/ dash
syn match cs2OperatorStart /-c\?/ nextgroup=cs2Operator
syn keyword cs2Operator eq ne ge gt lt le like notlike match notmatch replace /contains/ notcontains contained
syn keyword cs2Operator ieq ine ige igt ile ilt ilike inotlike imatch inotmatch ireplace icontains inotcontains contained
syn keyword cs2Operator ceq cne cge cgt clt cle clike cnotlike cmatch cnotmatch creplace ccontains cnotcontains contained
syn keyword cs2Operator is isnot as
syn keyword cs2Operator and or band bor not
syn keyword cs2Operator f

" Regular Strings
syn region cs2String start=/"/ skip=/`"/ end=/"/ 
syn region cs2String start=/'/ end=/'/  

" Here-Strings
syn region cs2String start=/@"$/ end=/^"@$/
syn region cs2String start=/@'$/ end=/^'@$/

" Numbers
syn match cs2Number /\<[0-9]\+/

" Setup default color highlighting
if version >= 508 || !exists("did_cs2_syn_inits")
  if version < 508
    let did_cs2_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink cs2String String
  HiLink cs2Conditional Conditional
  HiLink cs2Function Function
  HiLink cs2Variable Identifier
  HiLink cs2ScopedVariable Identifier
  HiLink cs2VariableName Identifier
  HiLink cs2Type Type
  HiLink cs2Scope Type
  HiLink cs2StandaloneType Type
  HiLink cs2Number Number
  HiLink cs2Comment Comment
  HiLink cs2CommentTodo Todo
  HiLink cs2Operator Operator
  HiLink cs2Repeat Repeat
  HiLink cs2RepeatAndCmdlet Repeat
  HiLink cs2Keyword Keyword
  HiLink cs2KeywordAndCmdlet Keyword
  HiLink cs2Cmdlet Statement

  HiLink cs2System Keyword
  HiLink cs2SystemName Identifier
  delcommand HiLink
endif

let b:current_syntax = "powershell"
