using FletcherChecksums
using Documenter

DocMeta.setdocmeta!(FletcherChecksums, :DocTestSetup, :(using FletcherChecksums); recursive=true)

makedocs(;
    modules=[FletcherChecksums],
    authors="Phil Killewald <reallyasi9@users.noreply.github.com> and contributors",
    sitename="FletcherChecksums.jl",
    format=Documenter.HTML(;
        canonical="https://reallyasi9.github.io/FletcherChecksums.jl",
        edit_link="development",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/reallyasi9/FletcherChecksums.jl",
    devbranch="development",
)
