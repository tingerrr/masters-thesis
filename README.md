# Masters Thesis: Containers under real time constraints
This repository hosts the thesis and supplementary poster for my masters thesis in applied computer science at the [University of Applied Sciences Erfurt (FHE)][FHE]. The title of this thesis is **Container unter Echtzeitbedingungen** (**Contianers under real time constraints**). At the time of writing this, the thesis is only available in German with an English abstract. After finishing the thesis (sucessfully), a translated version will be provided as I find the time for it.

## Copyright and Licensing
TODO: add this before releasing the sourcing code

## Compiling
This thesis is written in [Typst], to compile it, you need the Typst compiler. You can compile it yourself with a Rust toolchain by cloning [typst/typst], or by downloading the appropriate release for your platform and operating system.

Once installed, running `typst compile src/thesis.typ thesis.pdf` from this directory will compile the thesis into a PDF. The poster can likewise be compiled using `typst compile src/poster.typ poster.pdf`.

To compile either of the two aforementioned documents, an internet connection is required once per document to downlaod and cache the packges. Once all the packages in use are cached the documents can be compiled offline.

[Typst]: https://typst.app/
[typst/typst]: https://github.com/typst/typst
[FHE]: https://fh-erfurt.de
