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
typst *args:
	typst {{ args }}

# invoke typst for building with the given command and output type
build cmd type:
	typst {{ cmd }} {{ 'src' / lang / type + '.typ' }} {{ 'out' / type + '-' + lang + '.pdf' }}


# query the document for todos
lint type:
	typst query {{ 'src' / lang / type + '.typ' }} '<todo>'


# invoke typst-preview with the given output type
preview type:
	typst-preview --root {{ root }} {{ 'src' / lang / type + '.typ' }}


# compile the thesis once
thesis: (build 'compile' 'thesis')

# compile the poster once
poster: (build 'compile' 'poster')


# compile the thesis incrementally
watch-thesis: (build 'watch' 'thesis')

# compile the poster incrementally
watch-poster: (build 'watch' 'poster')


# preview the thesis
preview-thesis: (preview 'thesis')

# preview the poster
preview-poster: (preview 'poster')
