using SimpleChecksums
using Documenter

DocMeta.setdocmeta!(SimpleChecksums, :DocTestSetup, :(using SimpleChecksums); recursive=true)

makedocs(;
    modules=[SimpleChecksums],
    authors="Phil Killewald <reallyasi9@users.noreply.github.com> and contributors",
    sitename="SimpleChecksums.jl",
    format=Documenter.HTML(;
        canonical="https://reallyasi9.github.io/SimpleChecksums.jl",
        edit_link="development",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/reallyasi9/SimpleChecksums.jl",
    devbranch="development",
)
