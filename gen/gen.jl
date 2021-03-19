using Hashpipe_jll
using Clang
using Clang.LibClang.Clang_jll

# Headers and functions/structs not to wrap
const EXCLUDE_HEADERS = ["hashpipe_packet.h", "hashpipe_pktsock.h", "hashpipe_udp.h", "hashpipe_databuf.h", "hashpipe_status.h"]
const EXCLUDE_ITEMS = ["hgeti8", "hputi8", "hputu8", "hgetu8", "list_hashpipe_threads", "hashpipe_databuf_key", "hashpipe_databuf_wait_free_timeout", "hashpipe_databuf_wait_filled_timeout"
                    , "register_hashpipe_thread", "find_hashpipe_thread"]

# LIBHASHPIPE_HEADERS are those headers to be wrapped.
const LIBHASHPIPE_INCLUDE = joinpath(dirname(Hashpipe_jll.libhashpipe_path), "..", "include") |> normpath
const LIBHASHPIPE_HEADERS = [joinpath(LIBHASHPIPE_INCLUDE, header) for header in readdir(LIBHASHPIPE_INCLUDE) if(endswith(header, ".h") && !(header in EXCLUDE_HEADERS))]


"""
    exclude(name::String)

Return whether or not to exclude function/struct from auto-wrapping
"""
function exclude(name::String)::Bool
    for exclude_name in EXCLUDE_ITEMS
        if(startswith(name,exclude_name))
            return true
        end
    end
    return false
end

function basic_generator()
    println("Headers to parse: $LIBHASHPIPE_HEADERS")

    # TODO: In hashpipe.h: list_hashpipe_threads(f) requires FILE to be defined which we don't have
    # Add semaphore.h and FILE header into LIBHASHPIPE_INCLUDE string?

    wc = init(; headers = LIBHASHPIPE_HEADERS,
                output_file = joinpath(@__DIR__, "libhashpipe_api.jl"),
                common_file = joinpath(@__DIR__, "libhashpipe_common.jl"),
                clang_includes = vcat(LIBHASHPIPE_INCLUDE, CLANG_INCLUDE),
                clang_args = ["-I", joinpath(LIBHASHPIPE_INCLUDE, "..")],
                header_wrapped = (root, current)->root == current,
                header_library = x->"libhashpipe",
                clang_diagnostics = true,
                )

    run(wc)
end

# Excludes problematic functions
function advanced_generator()

    # create a work context
    ctx = DefaultContext()
    
    # parse headers
    parse_headers!(ctx, LIBHASHPIPE_HEADERS,
                   args=["-I", joinpath(LIBHASHPIPE_INCLUDE, "..")],
                   includes=vcat(LIBHASHPIPE_INCLUDE, CLANG_INCLUDE),
                   )
    
    # settings
    ctx.libname = "libhashpipe"
    ctx.options["is_function_strictly_typed"] = false
    ctx.options["is_struct_mutable"] = true
    
    # write output
    api_file = joinpath(@__DIR__, "..", "src", "wrapper", "libhashpipe_api.jl")
    api_stream = open(api_file, "w")
    
    for trans_unit in ctx.trans_units
        root_cursor = getcursor(trans_unit)
        push!(ctx.cursor_stack, root_cursor)
        header = spelling(root_cursor)
        @info "wrapping header: $header ..."
        # loop over all of the child cursors and wrap them, if appropriate.
        ctx.children = children(root_cursor)
        for (i, child) in enumerate(ctx.children)
            child_name = Clang.name(child)

            child_header = filename(child)
            ctx.children_index = i
            # choose which cursor to wrap
            exclude(child_name) && continue
            startswith(child_name, "__") && continue  # skip compiler definitions
            child_name in keys(ctx.common_buffer) && continue  # already wrapped
            child_header != header && continue  # skip if cursor filename is not in the headers to be wrapped
    
            wrap!(ctx, child)
        end
        @info "writing $(api_file)"
        println(api_stream, "# Julia wrapper for header: $(basename(header))")
        println(api_stream, "# Automatically generated using Clang.jl\n")
        print_buffer(api_stream, ctx.api_buffer)
        empty!(ctx.api_buffer)  # clean up api_buffer for the next header
    end
    close(api_stream)
    
    # Perhaps do not need to have the common file. Just do these manually as needed since so few

    # write "common" definitions: types, typealiases, etc.
    # common_file = joinpath(@__DIR__, "..", "src", "wrapper", "libhashpipe_common.jl")
    # open(common_file, "w") do f
    #     println(f, "# Automatically generated using Clang.jl\n")
    #     print_buffer(f, dump_to_buffer(ctx.common_buffer))
    # end
    
    # uncomment the following code to generate dependency and template files
    # copydeps(dirname(api_file))
    # print_template(joinpath(dirname(api_file), "LibTemplate.jl"))
end


advanced_generator()