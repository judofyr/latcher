# Latcher, a more precise Matcher

Latcher is a very simple [Matcher](https://github.com/burke/matcher)
(for CtrlP). It has the following (anti) features:

* No case-insensitivity.
* No fuzzy matching.
* Only match on prefixes, not in the middle of a word.

## Usage

Use the same function as Matcher, but replace the path:

```vim
" Latcher
let g:path_to_matcher = "latcher.lua"
let g:ctrlp_match_func = { 'match': 'GoodMatch' }

function! GoodMatch(items, str, limit, mmode, ispath, crfile, regex)

  " Create a cache file if not yet exists
  let cachefile = ctrlp#utils#cachedir().'/matcher.cache'
  if !( filereadable(cachefile) && a:items == readfile(cachefile) )
    call writefile(a:items, cachefile)
  endif
  if !filereadable(cachefile)
    return []
  endif

  " a:mmode is currently ignored. In the future, we should probably do
  " something about that. the matcher behaves like "full-line".
  let cmd = g:path_to_matcher.' --limit '.a:limit.' --manifest '.cachefile.' '
  if !( exists('g:ctrlp_dotfiles') && g:ctrlp_dotfiles )
    let cmd = cmd.'--no-dotfiles '
  endif
  let cmd = cmd.a:str

  return split(system(cmd), "\n")

endfunction
```

