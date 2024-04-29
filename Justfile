lang := 'de'
root := justfile_directory()

# typst variables
export TYPST_ROOT := root
export TYPST_FONT_PATHS := root / 'assets' / 'fonts'

# list recipes by default
[private]
default:
	@just --list --unsorted

# invoke typst with the given command and output type
typst *args:
	typst {{ args }}

# create the temporary and gitignored directories or files
[private]
prep:
	mkdir -p out

# compile the notes and supplementary material
notes: prep
	typst compile {{ 'etc' / 'notes.typ' }} {{ 'out' / 'notes.pdf' }}

# invoke typst for building with the given command and output type
build cmd type *args: prep
	typst {{ cmd }} {{ 'src' / lang / type + '.typ' }} {{ 'out' / type + '-' + lang + '.pdf' }} {{ args }}

# invoke typst compile for the given output type
compile type: (build 'compile' type)

#invoke typst watch for the given output type
watch type: (build 'watch' type)

# invoke typst-preview with the given output type
preview type *args:
	typst-preview --root {{ root }} {{ 'src' / lang / type + '.typ' }} {{ args }}

# query the document for todos
lint type:
	typst query {{ 'src' / lang / type + '.typ' }} '<todo>'
