using ExperimentsMultithreading
using Documenter

DocMeta.setdocmeta!(ExperimentsMultithreading, :DocTestSetup, :(using ExperimentsMultithreading); recursive=true)

makedocs(;
    modules=[ExperimentsMultithreading],
    authors="Isaia Nisoli",
    sitename="ExperimentsMultithreading.jl",
    format=Documenter.HTML(;
        canonical="https://orkolorko.github.io/ExperimentsMultithreading.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/orkolorko/ExperimentsMultithreading.jl",
    devbranch="main",
)
