using EvoLab
using Documenter

makedocs(;
    modules=[EvoLab],
    authors="i62lucum i62lucum@uco.es, SergioGmezM i62gomos@uco.es",
    repo="https://github.com/i62lucum/EvoLab.jl/blob/{commit}{path}#L{line}",
    sitename="EvoLab.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://i62lucum.github.io/EvoLab.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/i62lucum/EvoLab.jl",
)
