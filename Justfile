lang := 'de'
root := justfile_directory() / 'src'
assets := justfile_directory() / 'assets'

# typst variables
export TYPST_ROOT := root
export TYPST_FONT_PATHS := assets / 'fonts'

# list recipes by default
[private]
default:
	@just --list --unsorted

# invoke typst with the given command and output type
typst cmd type:
	typst {{ cmd }} {{ 'src' / lang / type + '.typ' }} {{ type + '-' + lang + '.pdf' }}


# invoke typst-preview with the given output type
preview type:
	typst-preview --root {{ root }} {{ 'src' / lang / type + '.typ' }}


# compile the thesis once
thesis: (typst 'compile' 'thesis')

# compile the poster once
poster: (typst 'compile' 'poster')


# compile the thesis incrementally
watch-thesis: (typst 'watch' 'thesis')

# compile the poster incrementally
watch-poster: (typst 'watch' 'poster')


# preview the thesis
preview-thesis: (preview 'thesis')

# preview the poster
preview-poster: (preview 'poster')
