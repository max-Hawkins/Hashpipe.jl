"""
    Hashpipe Module

C Hashpipe functions ported for Julia usability with pure-Julian extensions.
Written by Max Hawkins
Hashpipe C code written by Dave MacMahon: https://github.com/david-macmahon/hashpipe
"""
module Hashpipe

# Hashpipe error Codes
const HASHPIPE_OK         =  0
const HASHPIPE_TIMEOUT    =  1 # Call timed out 
const HASHPIPE_ERR_GEN    = -1 # Super non-informative
const HASHPIPE_ERR_SYS    = -2 # Failed system call
const HASHPIPE_ERR_PARAM  = -3 # Parameter out of range
const HASHPIPE_ERR_KEY    = -4 # Requested key doesn't exist
const HASHPIPE_ERR_PACKET = -5 # Unexpected packet size

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