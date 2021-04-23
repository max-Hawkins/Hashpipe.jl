abstract type HashpipeDatabuf end

"""
    databuf_t

"""
struct databuf_t <: HashpipeDatabuf
    data_type::NTuple{64, UInt8}
    header_size::Int # May need to change to Csize_t
    block_size::Int # May need to change to Csize_t
    n_block::Cint
    shmid::Cint
    semid::Cint
end

# These typedefs are used to declare pointers to a pipeline thread's init and
# run functions.
# typedef int (* initfunc_t)(thread_args_t *);
# typedef void * (* runfunc_t)(thread_args_t *);

# This typedefs are used to declare pointers to a pipline thread's data buffer
# create function.
# typedef databuf_t * (* databuf_createfunc_t)(int, int);

# typedef struct {
#   databuf_createfunc_t create;
# } databuf_desc_t;

"""
    databuf_desc_t

Struct containing
"""
struct databuf_desc_t
    """
    C-compatible pointer to Julia databuf create function
    Generate using @cfunction macro
    """
    create::Ptr{Cvoid}
end



function databuf_data(p_databuf::Ptr{databuf_t}, block_id::Int)
    p_data::Ptr{UInt8} = ccall((:hashpipe_databuf_data, libhashpipe),
                            Ptr{UInt8}, (Ptr{status_t}, Int8), p_databuf, block_id)
    return p_data
end

"""
    databuf_create(instance_id::Int, db_id::Int,
                            header_size::Int, block_size::Int, n_block::Int)

"""
function databuf_create(instance_id::Int, db_id::Int,
            header_size::Int, block_size::Int, n_block::Int)
    p_databuf::Ptr{databuf_t} =
            ccall((:hashpipe_databuf_create, libhashpipe),
                Ptr{databuf_t},
                (Int8, Int8, Int, Int, Int),
                instance_id, db_id, header_size, block_size, n_block)
    return p_databuf
end

function databuf_clear(p_databuf::Ptr{databuf_t})
    ccall((:hashpipe_databuf_clear, libhashpipe),
            Cvoid, (Ptr{status_t},), p_databuf)
    return nothing
end
function databuf_attach(instance_id::Int, db_id::Int)
    p_databuf::Ptr{databuf_t} = ccall((:hashpipe_databuf_attach, libhashpipe),
                    Ptr{databuf_t}, (Int8, Int8), instance_id, db_id)
    return p_databuf
end

function databuf_detach(p_databuf::Ptr{databuf_t})
    error::Int = ccall((:hashpipe_databuf_attach, libhashpipe),
                    Int, (Ptr{databuf_t},), p_databuf)
    return error
end

# Check hashpipe databuf status
"""
    check_databuf(instance_id=0, db_id=1)

Display databuf information with given databuf ID and instance ID.
"""
function check_databuf(instance_id::Int = 0, db_id::Int = 1)
    p_databuf = databuf_attach(instance_id, db_id)
    if p_databuf == C_NULL
        println("Error attaching to databuf $db_id (may not exist).")
        return nothing
    end
    println("--- Databuf $db_id Stats ---")
    display(p_databuf)
    return nothing
end

function databuf_block_status(p_databuf::Ptr{databuf_t}, block_id::Int)
    block_status::Int = ccall((:hashpipe_databuf_block_status, libhashpipe),
                    Int, (Ptr{databuf_t}, Int), p_databuf, block_id)
    return block_status
end

# Return total lock status for databuf
function databuf_total_status(p_databuf::Ptr{databuf_t})
    total_status::UInt64 = ccall((:hashpipe_databuf_total_status, libhashpipe),
                    Int, (Ptr{databuf_t},), p_databuf)
    return total_status
end

function databuf_total_mask(p_databuf::Ptr{databuf_t})
    total_mask::UInt64 = ccall((:hashpipe_databuf_total_mask, libhashpipe),
                    UInt64, (Ptr{databuf_t},), p_databuf)
    return total_mask
end

# Databuf locking functions.  Each block in the buffer
# can be marked as free or filled.  The "wait" functions
# block (i.e. sleep) until the specified state happens.
# The "busywait" functions busy-wait (i.e. do NOT sleep)
# until the specified state happens.  The "set" functions
# put the buffer in the specified state, returning error if
# it is already in that state.

function databuf_wait_filled(p_databuf::Ptr{databuf_t}, block_id::Int)
    error::Int = ccall((:hashpipe_databuf_wait_filled, libhashpipe),
                    Int, (Ptr{databuf_t}, Int), p_databuf, block_id)
    return error
end

function databuf_wait_free(p_databuf::Ptr{databuf_t}, block_id::Int)
    error::Int = ccall((:hashpipe_databuf_wait_free, libhashpipe),
                    Int, (Ptr{databuf_t}, Int), p_databuf, block_id)
    return error
end

function databuf_set_filled(p_databuf::Ptr{databuf_t}, block_id::Int)
    error::Int = ccall((:hashpipe_databuf_set_filled, libhashpipe),
                    Int, (Ptr{databuf_t}, Int), p_databuf, block_id)
    return error
end

function databuf_set_free(p_databuf::Ptr{databuf_t}, block_id::Int)
    error::Int = ccall((:hashpipe_databuf_set_free, libhashpipe),
                    Int, (Ptr{databuf_t}, Int), p_databuf, block_id)
    return error
end

"""
    Base.display(d::Hashpipe.databuf_t)

Display for hashpipe buffers.
"""
function Base.display(d::Hashpipe.databuf_t)
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

"""
    Base.display(p::Ptr{databuf_t})

Display hashpipe databuf from pointer
"""
function Base.display(p::Ptr{databuf_t})
    databuf::databuf_t = unsafe_wrap(Array, p, 1)[]
    display(databuf)
    return nothing
end

function status_buf_lock_unlock(f::Function, r_status::Ref{status_t})
        try
            status_lock(r_status)
            f() # or f(st) TODO: test which of these is better
        catch e
            @error "Error locking hashpipe status buffer - Error: $e"
        finally
            status_unlock(r_status)
        end
end
