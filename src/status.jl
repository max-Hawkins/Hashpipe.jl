export status_t, status_exists, status_attach, status_detach, status_lock, status_unlock,
        status_clear, status_chkinit, update_status, status_buf_lock_unlock

# Status constants
"""
    const global STATUS_TOTAL_SIZE = 184320

The maximum size of a HASHPIPE status buffer - 184,320 bytes.
"""
const global STATUS_TOTAL_SIZE = 184320 # 2880 * 64
"""
    const global STATUS_RECORD_SIZE = 80

The size of a status record - 80 characters.
"""
const global STATUS_RECORD_SIZE = 80

"""
    Hashpipe Status struct

Data representing a Hashpipe status buffer.

Need to create empty status struct before trying to attaching
to existing status buffer.
Example:
'''
    instance_id = 0
    status = status_t(0,0,0,0)
    status_attach(instance_id, Ref(status))
'''
"""
mutable struct status_t
    "Instance ID of this status buffer. DO NOT SET/CHANGE!"
    instance_id::Cint
    "Shared memory segment id."
    shmid::Cint
    "POSIX semaphore descriptor for locking "
    p_lock::Ptr{UInt8}
    "Pointer to data area."
    p_buf::Ptr{UInt8}
end

"""
    status_exists(instance_id)

Check whether or not the Hashpipe status buffer exists for the given Hashpipe instance.

Returns non-zero if the status buffer for instance already exists.
"""
function status_exists(instance_id::Int)
    exists::Int8 = ccall((:hashpipe_status_exists,
                libhashpipestatus),
                Int8, (Int8,), instance_id)
    return exists
end

"""
    status_attach(instance_id::Int, p_status::Ref{status_t})

Populate the Hashpipe status pointed to by p_status with the status values of the Hashpipe
instance given (created if doesn't already exist).

Attach/create lock semaphore as well.  Return nonzero on error.
"""
function status_attach(instance_id::Int, p_status::Ref{status_t})
    error::Int8 = ccall((:hashpipe_status_attach, libhashpipestatus),
                    Int, (Int, Ref{status_t}), instance_id, p_status)
    return error
end

function status_detach(p_status::Ref{status_t})
    error::Int8 = ccall((:hashpipe_status_detach, libhashpipestatus),
                    Int, (Ref{status_t}, ), p_status)
    return error
end

"""
    status_lock(p_status::Ref{status_t})

Lock the status pointed to by p_status (probably for updating status values).

If locked, will sleep while waiting for the buffer to become unlocked.
"""
function status_lock(p_status::Ref{status_t})
    error::Int8 = ccall((:hashpipe_status_lock, libhashpipestatus),
                    Int, (Ref{status_t},), p_status)
    return error
end

"""
    status_unlock(p_status::Ref{status_t})

Unlock the status pointed to by p_status (probably after updating status values).

If unlocked, will sleep while waiting for the buffer to become locked.
"""
function status_unlock(p_status::Ref{status_t})
    error::Int8 = ccall((:hashpipe_status_unlock, libhashpipestatus),
                    Int, (Ref{status_t},), p_status)
    return error
end

"""
    status_buf_lock_unlock(f::Function, r_status::Ref{status_t})

Safely lock and unlock a shared status buffer for updating its values. This must be done
so that the status buffer values aren't changed by multiple processes at the same time.

Example:

"""
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

"""
    status_clear(p_status::Ref{status_t})

Clear the status values of the status buffer shared memory.
"""
function status_clear(p_status::Ref{status_t})
    ccall((:hashpipe_status_clear, libhashpipestatus),
            Int, (Ref{status_t},), p_status)
    return nothing
end

""" 
    status_chkinit(p_status::Ref{status_t})

Check the status buffer for appropriate formatting (existence of "END").
If not found, zero it out and add END.
"""
function status_chkinit(p_status::Ref{status_t})
    ccall((:hashpipe_status_chkinit, libhashpipestatus),
            Int, (Ref{status_t},), p_status)
    return nothing
end


"""
    Base.display(s::status_t)

Display a Hashpipe status nicely in REPL.
"""
function Base.display(s::status_t)
    # Calculate max number of header records
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
        # Iterate through records and display them
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

"""
    Base.display(r::Ref{status_t})

Display Hashpipe status from reference nicely in REPL.
"""
function Base.display(r::Ref{status_t})
    display(r[])
    return nothing
end

# Todo Auto-generate all update_status possibilities

function update_status(status::status_t, key::String, value::String)::Int8
    key = Cstring(pointer(key)) # Need to convert for hput functions
    error::Int8 = ccall((:hputs, libhashpipestatus),
                    Int, (Ptr{UInt8}, Cstring, Cstring),
                    status.p_buf, Cstring(pointer(key)), Cstring(pointer(value)))
    return error
end

function update_status(status::status_t, key::String, value::Int)::Int8
    key = Cstring(pointer(key)) # Need to convert for hput functions
    error::Int8 = ccall((:hputi4, libhashpipestatus),
                    Int, (Ptr{UInt8}, Cstring, Cint),
                    status.p_buf, Cstring(pointer(key)), Cint(value))
    return error
end
