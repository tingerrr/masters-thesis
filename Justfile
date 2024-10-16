root := justfile_directory()

# typst environment variables
export TYPST_ROOT := root
export TYPST_FONT_PATHS := root / 'assets' / 'fonts'

# overridable variables
lang := 'de'
target := 'thesis'

# compound file paths
main_file := 'src' / lang / target + '.typ'
build_file := 'build' / target + '-' + lang + '.pdf'
persist_file := 'out' / target + '-' + lang + '.pdf'

# list recipes by default
[private]
default:
	@just --list --unsorted

# print a help message
help:
	# There are three targets available for building, which correspond to the three
	# entry points, they can be set by running just with `target=<target> build`:
	# - thesis (default)
	# - poster
	# - presentation
	#
	# Running typst itself with the right root and font directories can be done by
	# simply running `just typst <args...>`.

# invoke typst with some pre-set environment variables
typst *args:
	typst {{ args }}

# create temporary directories and files
[private]
prepare:
	mkdir -p build

# compile once
build *args:
	typst compile {{ main_file }} {{ build_file }} {{ args }}

# compile incrementally
watch *args:
	typst watch {{ main_file }} {{ build_file }} {{ args }}

# compile once and persist this version in the repo
update *args: prepare (build args)
	cp -u {{ build_file }} {{ persist_file }}

# export the pdfpc file
pdfpc: prepare
	#! /usr/bin/env nu
	typst query {{ 'src' / lang / 'presentation.typ' }} --field value --one <pdfpc-file> | from json | to json | save -f {{ 'build' / 'presentation-' + lang + ".pdfpc" }}
