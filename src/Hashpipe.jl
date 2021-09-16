"""
    Hashpipe Module

C Hashpipe functions for the High-Availablity Shared Pipeline Engine ported for Julia usability with pure-Julian extensions.
Written by Max Hawkins
Hashpipe C code written by Dave MacMahon: https://github.com/david-macmahon/hashpipe
"""
module Hashpipe

# Hashpipe error Codes
"""
    HASHPIPE_OK

Status code signifying successful operation.
"""
const HASHPIPE_OK         =  0
"""
    HASHPIPE_TIMEOUT

Status code signifying call timeout.
"""
const HASHPIPE_TIMEOUT    =  1 
"""
    HASHPIPE_ERR_GEN

Status code signifying an unknown error?
"""
const HASHPIPE_ERR_GEN    = -1 # Super non-informative???
"""
    HASHPIPE_ERR_SYS

Status code signifying a failed system call.
"""
const HASHPIPE_ERR_SYS    = -2
"""
    HASHPIPE_ERR_PARAM

Status code signifying parameter out of valid range.
"""
const HASHPIPE_ERR_PARAM  = -3
"""
    HASHPIPE_ERR_KEY

Status code signifying requested key doesn't exist.
"""
const HASHPIPE_ERR_KEY    = -4
"""
    HASHPIPE_ERR_PACKET

Status code signifying unexpected packet size.
"""
const HASHPIPE_ERR_PACKET = -5

# Inlcude libhashpipe and libhashpipestatus paths for C-calls
const deps_file = joinpath(dirname(@__FILE__),"..","deps","deps.jl")
if isfile(deps_file)
    include(deps_file)
else
    error("Hashpipe library not properly installed. Have you built Hashpipe? Try Pkg.build(\"Hashpipe\")")
end

include("status.jl")
include("databuf.jl")
include("fitshead.jl")
include("thread.jl")

end # Module Hashpipe