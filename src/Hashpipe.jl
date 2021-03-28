"""
    Hashpipe Module

C Hashpipe functions ported for Julia usability.
Written by Max Hawkins
Hashpipe C code written by Dave MacMahon: https://github.com/david-macmahon/hashpipe
"""
module Hashpipe

# Include custom-wrapped functions from Hashpipe_jll
include("./wrapper/libhashpipe_api_custom.jl")
# Inlcude Clang auto-wrapped functions from Hashpipe_jll installed library
include("./wrapper/libhashpipe_api_auto.jl") 

# export hashpipe_databuf_t, hashpipe_status_t

const deps_file = joinpath(dirname(@__FILE__),"..","deps","deps.jl")
if isfile(deps_file)
    include(deps_file)
else
    error("Hashpipe library not properly installed. Have you built Hashpipe? Try Pkg.build(\"Hashpipe\")")
end

# Hashpipe thread abstract type
abstract type HashpipeThread end

function init(thread::HashpipeThread)
    @error "Using default Hashpipe thread init function. Define a specific init function."
end

function run(thread::HashpipeThread)
    @error "Using default Hashpipe thread run function. Define a specific run function."
end

#----------#
# Displays #
#----------#

"Display hashpipe status"
function Base.display(s::hashpipe_status_t)
    BUFFER_MAX_RECORDS = Int(STATUS_TOTAL_SIZE / STATUS_RECORD_SIZE)
    println("Instance ID: $(s.instance_id)")
    println("shmid: $(s.shmid)")

    # Check to see if valid pointer
    if s.p_lock != C_NULL
        lock = unsafe_wrap(Array, s.p_lock, (1))[1]
        println("Lock: $lock")
    else
        println("Lock: NULL")
    end

    # Check to see if valid pointer
    if s.p_buf != C_NULL
        println("Buffer:")    
        string_array = unsafe_wrap(Array, s.p_buf, (STATUS_RECORD_SIZE, BUFFER_MAX_RECORDS))
        for record in 1:size(string_array, 2)
            record_string = String(string_array[:, record])
            println("\t", record_string)
            if record_string[1:3] == "END"
                return nothing
            end
        end
    else
        println("Buffer: NULL")
    end
    return nothing
end

"Display hashpipe status from reference"
function Base.display(r::Ref{hashpipe_status_t})
    display(r[])
    return nothing
end

"Display hashpipe buffer"
function Base.display(d::Hashpipe.hashpipe_databuf_t)
    # Convert Ntuple to array and strip 0s before converting to string
    data_type_string = String(filter(x->x!=0x00, collect(d.data_type)))
    println("Data Type: $(data_type_string)")
    println("Header Size: $(d.header_size)")
    println("Num Blocks: $(d.n_block)")
    println("Block Size: $(d.block_size)")
    println("shmid: $(d.shmid)")
    println("semid: $(d.semid)")
    return nothing
end

"Display hashpipe databuf from pointer"
function Base.display(p::Ptr{hashpipe_databuf_t})
    databuf::hashpipe_databuf_t = unsafe_wrap(Array, p, 1)[]
    display(databuf)
    return nothing
end

function hashpipe_status_buf_lock_unlock(f::Function, r_status::Ref{hashpipe_status_t})
        try
            hashpipe_status_lock(r_status)
            f() # or f(st) TODO: test which of these is better
        catch e
            @error "Error locking hashpipe status buffer - Error: $e"
        finally
            hashpipe_status_unlock(r_status)
        end
end


#----------------#
# Hput Functions #
#----------------#

# Todo Auto-generate all update_status possibilities

function update_status(status::hashpipe_status_t, key::String, value::String)::Int8
    key = Cstring(pointer(key)) # Need to convert for hput functions
    error::Int8 = ccall((:hputs, "libhashpipestatus.so"),
                    Int, (Ptr{UInt8}, Cstring, Cstring),
                    status.p_buf, Cstring(pointer(key)), Cstring(pointer(value)))
    return error
end

function update_status(status::hashpipe_status_t, key::String, value::Int)::Int8
    key = Cstring(pointer(key)) # Need to convert for hput functions
    error::Int8 = ccall((:hputi4, "libhashpipestatus.so"),
                    Int, (Ptr{UInt8}, Cstring, Cint),
                    status.p_buf, Cstring(pointer(key)), Cint(value))
    return error
end

# TODO: Auto-generate multiple dispatch for hput

# Auto-convert Julia string to Cstring
function hputs(p_hstring::Ptr{UInt8}, p_keyword::String, p_cval::String)
    error::Int = ccall((:hputs, "libhashpipestatus.so"),
                    Int, (Ptr{UInt8}, Cstring, Cstring),
                    p_hstring, Cstring(pointer(p_keyword)), Cstring(pointer(p_cval)))
    return error
end

function hputi4(p_hstring::Ptr{UInt8}, p_keyword::Cstring, p_ival::Cint)
    error::Int = ccall((:hputi4, "libhashpipestatus.so"),
                    Int, (Ptr{UInt8}, Cstring, Cint),
                    p_hstring, p_keyword, p_ival)
    return error
end
# Auto-convert julia string/int to Cstring/Cint
function hputi4(p_hstring::Ptr{UInt8}, p_keyword::String, p_ival::Int)
    error::Int = ccall((:hputi4, "libhashpipestatus.so"),
                    Int, (Ptr{UInt8}, Cstring, Cint),
                    p_hstring, Cstring(pointer(p_keyword)), Cint(p_ival))
    return error
end

end # Module Hashpipe


function pin_databuf_mem(db, bytes=-1)
    if(bytes==-1) # If bytes not specified, use databuf block size (may be incorrect)
        bytes = db.block_size
    end

    hp_databuf = unsafe_wrap(Array{Main.Hashpipe.hashpipe_databuf_t}, db.p_hpguppi_db, (1))[1];
    println("Pinning $bytes of Memory:")
    for i in 1:hp_databuf.n_block
        println("Block: $i")
        # Get correct buffer size from databuf!
        CUDA.Mem.register(CUDA.Mem.HostBuffer,db.blocks[i].p_data , bytes)
    end
end
