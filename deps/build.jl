using Hashpipe_jll

# include("../gen/gen.jl")

const depsfile = joinpath(@__DIR__, "deps.jl")

open(depsfile, "w") do f
    # Path to Hashpipe_jll build hashpipe shared object files:
    deps_string = "const libhashpipe = \"$(Hashpipe_jll.libhashpipe_path)\""
    print(f, deps_string)
    println(f)
end

