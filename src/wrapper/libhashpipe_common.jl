# Automatically generated using Clang.jl


const INT8_FMT = "%ld"
const UINT8_FMT = "%lu"
const int8 = Clong
const uint8 = Culong
const HASHPIPE_VERSION = "1.8"

# Skipping MacroDefinition: THREAD_OK ( ( void * ) 0 )
# Skipping MacroDefinition: THREAD_ERROR ( ( void * ) - 1 )

const MAX_HASHPIPE_THREADS = 1024
const initfunc_t = Ptr{Cvoid}
const runfunc_t = Ptr{Cvoid}
const databuf_createfunc_t = Ptr{Cvoid}

mutable struct databuf_desc_t
    create::databuf_createfunc_t
end

mutable struct hashpipe_thread_desc
    name::Cstring
    skey::Cstring
    init::initfunc_t
    run::runfunc_t
    ibuf_desc::databuf_desc_t
    obuf_desc::databuf_desc_t
end

const hashpipe_thread_desc_t = hashpipe_thread_desc

mutable struct hashpipe_status_t
    instance_id::Cint
    shmid::Cint
    lock::Ptr{sem_t}
    buf::Cstring
end

mutable struct hashpipe_databuf_t
    data_type::NTuple{64, UInt8}
    header_size::Csize_t
    block_size::Csize_t
    n_block::Cint
    shmid::Cint
    semid::Cint
end

mutable struct hashpipe_thread_args
    thread_desc::Ptr{hashpipe_thread_desc_t}
    instance_id::Cint
    input_buffer::Cint
    output_buffer::Cint
    cpu_mask::UInt32
    finished::Cint
    finished_c::pthread_cond_t
    finished_m::pthread_mutex_t
    st::hashpipe_status_t
    ibuf::Ptr{hashpipe_databuf_t}
    obuf::Ptr{hashpipe_databuf_t}
    user_data::Ptr{Cvoid}
end

const hashpipe_thread_args_t = hashpipe_thread_args
const HASHPIPE_OK = 0
const HASHPIPE_TIMEOUT = 1
const HASHPIPE_ERR_GEN = -1
const HASHPIPE_ERR_SYS = -2
const HASHPIPE_ERR_PARAM = -3
const HASHPIPE_ERR_KEY = -4
const HASHPIPE_ERR_PACKET = -5
const DEBUGOUT = 0

# Skipping MacroDefinition: TPACKET_HDR ( p , h ) ( ( ( struct tpacket_hdr * ) p ) -> h )
# Skipping MacroDefinition: PKT_MAC ( p ) ( p + TPACKET_HDR ( p , tp_mac ) )
# Skipping MacroDefinition: PKT_NET ( p ) ( p + TPACKET_HDR ( p , tp_net ) )
# Skipping MacroDefinition: PKT_IS_UDP ( p ) ( ( PKT_NET ( p ) [ 0x09 ] ) == IPPROTO_UDP )
# Skipping MacroDefinition: PKT_UDP_DST ( p ) ( ( ( PKT_NET ( p ) [ 0x16 ] ) << 8 ) | ( ( PKT_NET ( p ) [ 0x17 ] ) ) )
# Skipping MacroDefinition: PKT_UDP_SIZE ( p ) ( ( ( PKT_NET ( p ) [ 0x18 ] ) << 8 ) | ( ( PKT_NET ( p ) [ 0x19 ] ) ) )
# Skipping MacroDefinition: PKT_UDP_DATA ( p ) ( PKT_NET ( p ) + 0x1c )

mutable struct hashpipe_pktsock
    frame_size::UInt32
    nframes::UInt32
    nblocks::UInt32
    fd::Cint
    p_ring::Ptr{Cuchar}
    next_idx::Cint
end

const HASHPIPE_STATUS_TOTAL_SIZE = 2880 * 64
const HASHPIPE_STATUS_RECORD_SIZE = 80

# Skipping MacroDefinition: hashpipe_status_lock_safe ( s ) pthread_cleanup_push ( ( void ( * ) ( void * ) ) hashpipe_status_unlock , s ) ; hashpipe_status_lock ( s ) ;
# Skipping MacroDefinition: hashpipe_status_lock_busywait_safe ( s ) pthread_cleanup_push ( ( void ( * ) ( void * ) ) hashpipe_status_unlock , s ) ; hashpipe_status_lock_busywait ( s ) ;
# Skipping MacroDefinition: hashpipe_status_unlock_safe ( s ) hashpipe_status_unlock ( s ) ; pthread_cleanup_pop ( 0 ) ;

const HASHPIPE_MAX_PACKET_SIZE = 9600

mutable struct hashpipe_udp_params
    sender::NTuple{80, UInt8}
    port::Cint
    bindhost::NTuple{80, UInt8}
    bindport::Cint
    packet_size::Csize_t
    packet_format::NTuple{32, UInt8}
    sock::Cint
    sender_addr::addrinfo
    pfd::pollfd
end

mutable struct hashpipe_udp_packet
    packet_size::Csize_t
    data::NTuple{9600, UInt8}
end
