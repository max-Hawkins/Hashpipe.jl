
# Hashpipe error Codes
const global HASHPIPE_OK         =  0
const global HASHPIPE_TIMEOUT    =  1 # Call timed out 
const global HASHPIPE_ERR_GEN    = -1 # Super non-informative
const global HASHPIPE_ERR_SYS    = -2 # Failed system call
const global HASHPIPE_ERR_PARAM  = -3 # Parameter out of range
const global HASHPIPE_ERR_KEY    = -4 # Requested key doesn't exist
const global HASHPIPE_ERR_PACKET = -5 # Unexpected packet size

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

# Status constants
const global STATUS_TOTAL_SIZE = 184320 # 2880 * 64
const global STATUS_RECORD_SIZE = 80

"""
Hashpipe Status struct

May need to create empty status struct before trying to attaching
to existing status buffer.
Example:
'''
    instance_id = 0
    status = status_t(0,0,0,0)
    status_attach(instance_id, Ref(r_status))
'''
"""
mutable struct status_t
    instance_id::Cint
    shmid::Cint
    p_lock::Ptr{UInt8} 
    p_buf::Ptr{UInt8}
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

struct databuf_desc_t
    # C-compatible pointer to Julia databuf create function
    # Generate using @cfunction macro
    create::Ptr{Cvoid}
end


# The thread_desc structure is used to store metadata describing a
# hashpipe thread.  Typically a hashpipe plugin will define one of these
# hashpipe thread descriptors per hashpipe thread.
# struct thread_desc {
#   const char * name;
#   const char * skey;
#   initfunc_t init;
#   runfunc_t run;
#   databuf_desc_t ibuf_desc;
#   databuf_desc_t obuf_desc;
# };

struct thread_desc_t
    name::Cstring # TODO: Double check on NULL terminated assumption with Dave
    skey::Cstring # ^^
    init::Ptr{Cvoid}
    run::Ptr{Cvoid}
    ibuf_desc::databuf_desc_t
    obuf_desc::databuf_desc_t
end


mutable struct thread_args_t
    thread_desc::Ptr{thread_desc_t}
    instance_id::Cint
    input_buffer::Cint
    output_buffer::Cint
    cpu_mask::UInt32
    finished::Cint
    finished_c::Ptr{Cvoid} # TODO: Change to mimic pthread_cond_t
    finished_m::Ptr{Cvoid} # TODO: Change to mimic pthread_mutex_t
    st::status_t
    ibuf::Ptr{databuf_t}
    obuf::Ptr{databuf_t}
    user_data::Ptr{Cvoid}
end

function register_hashpipe_thread(ptm)
    ccall((:register_hashpipe_thread, libhashpipe), Cint, (Ptr{thread_desc_t},), ptm)
end

function find_hashpipe_thread(name)
    ccall((:find_hashpipe_thread, libhashpipe), Ptr{thread_desc_t}, (Cstring,), name)
end


#---------------------------#
# Hashpipe Status Functions #
#---------------------------#


function status_exists(instance_id::Int)
    exists::Int8 = ccall((:hashpipe_status_exists, 
                libhashpipestatus), 
                Int8, (Int8,), instance_id)
    return exists
end

function status_attach(instance_id::Int, p_status::Ref{status_t})
    error::Int8 = ccall((:hashpipe_status_attach, libhashpipestatus),
                    Int, (Int8, Ref{status_t}), instance_id, p_status)
    return error
end

function status_lock(p_status::Ref{status_t})
    error::Int8 = ccall((:hashpipe_status_lock, libhashpipestatus),
                    Int, (Ref{status_t},), p_status)
    return error
end

function status_unlock(p_status::Ref{status_t})
    error::Int8 = ccall((:hashpipe_status_unlock, libhashpipestatus),
                    Int, (Ref{status_t},), p_status)
    return error
end


function status_clear(p_status::Ref{status_t})
    ccall((:hashpipe_status_clear, libhashpipestatus),
            Int, (Ref{status_t},), p_status)
    return nothing
end

#----------------------------#
# Hashpipe Databuf Functions #
#----------------------------#

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
