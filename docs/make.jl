using Documenter, Hashpipe

makedocs(sitename="Hashpipe Documentation", format = Documenter.HTML(prettyurls = false))

deploydocs(
    repo = "github.com/max-Hawkins/Hashpipe.jl.git",
)