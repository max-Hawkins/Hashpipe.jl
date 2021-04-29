# Hashpipe thread abstract type
abstract type HashpipeThread end

function init(thread::HashpipeThread)
    @error "Using default Hashpipe thread init function. Define a specific init function."
end

function run(thread::HashpipeThread)
    @error "Using default Hashpipe thread run function. Define a specific run function."
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
"""
    thread_desc_t

Metadata describing a Hashpipe threa (usually defined by a plugin per thread).
"""
struct thread_desc_t
    name::Cstring # TODO: Double check on NULL terminated assumption with Dave
    skey::Cstring # ^^
    init::Ptr{Cvoid}
    run::Ptr{Cvoid}
    ibuf_desc::databuf_desc_t
    obuf_desc::databuf_desc_t
end

"""
    thread_args_t

Implementation data for a Hashpipe thread.
"""
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

function run_threads()
    ccall((:run_threads, libhashpipe), Cint, ())
end

function get_cpu_affinity()
    ccall((:get_cpu_affinity, libhashpipe), UInt32, ())
end
