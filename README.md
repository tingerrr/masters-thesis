# Masters Thesis: Dynamic data structures under real time constraints
This repository hosts the thesis and supplementary poster for my masters thesis in applied computer science at the [University of Applied Sciences Erfurt (FHE)][FHE]. The title of this thesis is **Dynamische Datenstrukturen unter Echtzeitbedingungen** (**Dynamic data structures under real time constraints**). At the time of writing this, the thesis is only available in German with an English abstract. After finishing the thesis (sucessfully), a translated version will be provided as I find the time for it.

## Copyright and Licensing
TODO: add this before releasing the sourcing code

## Compiling
This thesis is written in [Typst], to compile it, you need the Typst compiler. You can compile it yourself with a Rust toolchain by cloning [typst/typst], or by downloading the appropriate release for your platform and operating system.

Once installed, run the following within this directory from a sh compatible shell:
```bash
export TYPST_ROOT="$(pwd)"
export TYPST_FONT_PATHS="$(pwd)/assets/fonts"
lang="de"     # or "en"
type="thesis" # or "poster"

mkdir -p out
typst compile "src/${lang}/${type}.typ" "out/${type}-${lang}.pdf"
```

To compile either of the two aforementioned documents, an internet connection is required once per document to download and cache the packges. Once all the packages in use are cached the documents can be compiled offline.

Additionally, the [Justfile] contains various useful recipes, mitigating the need for manually setting the environment variables.

To use a non-sh-compatible shell, refer to it's documentation on how to export environment
variables, or consider simply using [just].

[Justfile]: ./Justfile

[Typst]: https://typst.app/
[typst/typst]: https://github.com/typst/typst
[FHE]: https://fh-erfurt.de
[just]: https://just.systems
