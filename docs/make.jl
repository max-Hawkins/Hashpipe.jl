using Documenter, Hashpipe

makedocs(sitename="Hashpipe Documentation",
         modules = [Hashpipe],
)

deploydocs(
    repo = "github.com/max-Hawkins/Hashpipe.jl.git",
    devbranch = "main"
)