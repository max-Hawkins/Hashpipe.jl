using Hashpipe_jll

const depsfile = joinpath(@__DIR__, "deps.jl")

open(depsfile, "w") do f
    # Path to Hashpipe_jll build hashpipe shared object files:
    deps_string = "const libhashpipe = \"$(Hashpipe_jll.libhashpipe_path)\"\n" # libhashpipe.so
    deps_string *= "const libhashpipestatus = \"$(normpath(joinpath(Hashpipe_jll.libhashpipe_path, "../libhashpipestatus.so")))\"\n"
    print(f, deps_string)
end

