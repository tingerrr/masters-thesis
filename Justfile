LANG := 'de'

[private]
default:
	@just --list --unsorted

[private]
build cmd type lang:
	typst {{ cmd }} {{ 'src' / lang / type + '.typ' }} {{ type + '-' + lang + '.pdf' }}

# compile the thesis once
thesis: (build 'compile' 'thesis' LANG)

# compile the poster once
poster: (build 'compile' 'poster' LANG)

# compile the thesis incrementally
watch-thesis: (build 'watch' 'thesis' LANG)

# compile the poster incrementally
watch-poster: (build 'watch' 'poster' LANG)
