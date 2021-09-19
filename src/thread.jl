export register_hashpipe_thread, find_hashpipe_thread

# Hashpipe thread abstract type
"""
    HashpipeThread

Abstract type describing a Hashpipe thread.

    name - A string containing the thread's name. Used to match command line
            thread spcifiers to thread metadata so that the pipeline can be 
            constructed as specified on the command line.
    skey - A string containing the thread's status buffer "status" key.
            Typically 8 characters or less, uppercase, and ends with "STAT".
            If it is non-NULL and non-empty, HASHPIPE will automatically 
            store/update this key in the status buffer with the thread's 
            status at initialization ("init") and exit ("exit").
    init - A pointer to the thread's initialization function.
    run  - A pointer to the thread's run function.
    ibuf - A structure describing the thread's input data buffer (if any).
    obuf - A structure describing the thread's output data buffer (if any).

## Description of Hashpipe threads
A hashpipe_thread structure encapsulates metadata and functionality for one
or more threads that can be used in a processing pipeline.  The hashpipe
executable dynamically assembles a pipeline at runtime consisting of
multiple hashpipe threads.

Hashpipe threads must register themselves with the hashpipe executable via a
call to register_hashpipe_thread().  This is typically performed from a
static C function with the constructor attribute in the hashpipe thread's
source file.

Hashpipe threads are identified by their name.  The hashpipe executable
finds (registered) hashpipe threads by their name.  A hashpipe thread can be
input-only, output-only, or both input and output.  An input thread has an
associated output data buffer into which it writes data.  An output thread
has an associated input data buffer from which it reads data.  An
input/output thread has both.

Input-only threads source data into the pipeline.  They do not get their
input data from a shared memory ring buffer.  They get their data from
external sources (e.g.  files or the network) or generate it internally
(e.g.  for test vectors).  Input-only threads have an output data buffer,
but no input data buffer (their input does not come from a shared memory
ring buffer).

Output-only threads sink data from the pipeline.  Thy do not put their
output data into a shared memory ring buffer.  They send their data to
external sinks (e.g. files or the network) of consume it internally (e.g.
comparing against expected output).  Output-only threads have an input data
buffer, but no output data buffer (their output data does not go the a
shared memory ring buffer).

Input/output threads get their input data from one shared memory region
(their input data buffer), process it, and store the output data in another
shared memory region (their output data buffer).
"""
abstract type HashpipeThread end

function init(thread::HashpipeThread)
    @error "Using default Hashpipe thread init function. Define a specific init function."
end

function run(thread::HashpipeThread)
    @error "Using default Hashpipe thread run function. Define a specific run function."
end

"""
    THREAD_OK

OK status from run.
"""
const global THREAD_OK  = 0
"""
    THREAD_ERROR

Error status from run.
"""
const global THREAD_ERROR = -1
"""
    MAX_HASHPIPE_THREADS

Maximum number of threads that be defined by plugins.
"""
const global MAX_HASHPIPE_THREADS = 1024

"""
    thread_desc_t

Metadata describing a Hashpipe thread (usually defined by a plugin per thread).

The thread_desc structure is used to store metadata describing a hashpipe thread.  
Typically a hashpipe plugin will define one of these hashpipe thread 
descriptors per hashpipe thread.
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

"""
    register_hashpipe_thread(ptm)

Register a Hashpipe thread with the pipeline executable.
"""
function register_hashpipe_thread(ptm)
    ccall((:register_hashpipe_thread, libhashpipe), Cint, (Ptr{thread_desc_t},), ptm)
end

"""
    find_hashpipe_thread(name)

Find a Hashpipe thread with the given name.

Generally used only by the hashpipe executable.  Returns a pointer to its
hashpipe_thread_desc_t structure or NULL if a test with the given name is not found.

Names are case-sensitive.
"""
function find_hashpipe_thread(name)
    ccall((:find_hashpipe_thread, libhashpipe), Ptr{thread_desc_t}, (Cstring,), name)
end

"""
    run_threads()

Function that threads use to determine whether to keep running.
"""
function run_threads()
    ccall((:run_threads, libhashpipe), Cint, ())
end

"""
    get_cpu_affinity()
"""
function get_cpu_affinity()
    ccall((:get_cpu_affinity, libhashpipe), UInt32, ())
end
