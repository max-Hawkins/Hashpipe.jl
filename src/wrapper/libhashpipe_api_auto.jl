# Julia wrapper for header: fitshead.h
# Automatically generated using Clang.jl


function hgeti2(hstring, keyword, val)
    ccall((:hgeti2, libhashpipe), Cint, (Cstring, Cstring, Ptr{Int16}), hstring, keyword, val)
end

function hgeti4c(hstring, keyword, wchar, val)
    ccall((:hgeti4c, libhashpipe), Cint, (Cstring, Cstring, Cstring, Ptr{Cint}), hstring, keyword, wchar, val)
end

function hgeti4(hstring, keyword, val)
    ccall((:hgeti4, libhashpipe), Cint, (Cstring, Cstring, Ptr{Cint}), hstring, keyword, val)
end

function hgetu4(hstring, keyword, val)
    ccall((:hgetu4, libhashpipe), Cint, (Cstring, Cstring, Ptr{UInt32}), hstring, keyword, val)
end

function hgetr4(hstring, keyword, val)
    ccall((:hgetr4, libhashpipe), Cint, (Cstring, Cstring, Ptr{Cfloat}), hstring, keyword, val)
end

function hgetr8c(hstring, keyword, wchar, val)
    ccall((:hgetr8c, libhashpipe), Cint, (Cstring, Cstring, Cstring, Ptr{Cdouble}), hstring, keyword, wchar, val)
end

function hgetr8(hstring, keyword, val)
    ccall((:hgetr8, libhashpipe), Cint, (Cstring, Cstring, Ptr{Cdouble}), hstring, keyword, val)
end

function hgetra(hstring, keyword, ra)
    ccall((:hgetra, libhashpipe), Cint, (Cstring, Cstring, Ptr{Cdouble}), hstring, keyword, ra)
end

function hgetdec(hstring, keyword, dec)
    ccall((:hgetdec, libhashpipe), Cint, (Cstring, Cstring, Ptr{Cdouble}), hstring, keyword, dec)
end

function hgetdate(hstring, keyword, date)
    ccall((:hgetdate, libhashpipe), Cint, (Cstring, Cstring, Ptr{Cdouble}), hstring, keyword, date)
end

function hgetl(hstring, keyword, lval)
    ccall((:hgetl, libhashpipe), Cint, (Cstring, Cstring, Ptr{Cint}), hstring, keyword, lval)
end

function hgetsc(hstring, keyword, wchar, lstr, string)
    ccall((:hgetsc, libhashpipe), Cint, (Cstring, Cstring, Cstring, Cint, Cstring), hstring, keyword, wchar, lstr, string)
end

function hgets(hstring, keyword, lstr, string)
    ccall((:hgets, libhashpipe), Cint, (Cstring, Cstring, Cint, Cstring), hstring, keyword, lstr, string)
end

function hgetndec(hstring, keyword, ndec)
    ccall((:hgetndec, libhashpipe), Cint, (Cstring, Cstring, Ptr{Cint}), hstring, keyword, ndec)
end

function hgetc(hstring, keyword)
    ccall((:hgetc, libhashpipe), Cstring, (Cstring, Cstring), hstring, keyword)
end

function hgetc_thread_safe(hstring, keyword, value_buffer)
    ccall((:hgetc_thread_safe, libhashpipe), Cstring, (Cstring, Cstring, Cstring), hstring, keyword, value_buffer)
end

function ksearch(hstring, keyword)
    ccall((:ksearch, libhashpipe), Cstring, (Cstring, Cstring), hstring, keyword)
end

function blsearch(hstring, keyword)
    ccall((:blsearch, libhashpipe), Cstring, (Cstring, Cstring), hstring, keyword)
end

function strsrch(s1, s2)
    ccall((:strsrch, libhashpipe), Cstring, (Cstring, Cstring), s1, s2)
end

function strnsrch(s1, s2, ls1)
    ccall((:strnsrch, libhashpipe), Cstring, (Cstring, Cstring, Cint), s1, s2, ls1)
end

function strcsrch(s1, s2)
    ccall((:strcsrch, libhashpipe), Cstring, (Cstring, Cstring), s1, s2)
end

function strncsrch(s1, s2, ls1)
    ccall((:strncsrch, libhashpipe), Cstring, (Cstring, Cstring, Cint), s1, s2, ls1)
end

function hlength(header, lhead)
    ccall((:hlength, libhashpipe), Cint, (Cstring, Cint), header, lhead)
end

function gethlength(header)
    ccall((:gethlength, libhashpipe), Cint, (Cstring,), header)
end

function str2ra(in)
    ccall((:str2ra, libhashpipe), Cdouble, (Cstring,), in)
end

function str2dec(in)
    ccall((:str2dec, libhashpipe), Cdouble, (Cstring,), in)
end

function isnum(string)
    ccall((:isnum, libhashpipe), Cint, (Cstring,), string)
end

function notnum(string)
    ccall((:notnum, libhashpipe), Cint, (Cstring,), string)
end

function numdec(string)
    ccall((:numdec, libhashpipe), Cint, (Cstring,), string)
end

function strfix(string, fillblank, dropzero)
    ccall((:strfix, libhashpipe), Cvoid, (Cstring, Cint, Cint), string, fillblank, dropzero)
end

function getltime()
    ccall((:getltime, libhashpipe), Cstring, ())
end

function getutime()
    ccall((:getutime, libhashpipe), Cstring, ())
end

function hputi2(hstring, keyword, ival)
    ccall((:hputi2, libhashpipe), Cint, (Cstring, Cstring, Int16), hstring, keyword, ival)
end

function hputi4(hstring, keyword, ival)
    ccall((:hputi4, libhashpipe), Cint, (Cstring, Cstring, Cint), hstring, keyword, ival)
end

function hputu4(hstring, keyword, ival)
    ccall((:hputu4, libhashpipe), Cint, (Cstring, Cstring, UInt32), hstring, keyword, ival)
end

function hputr4(hstring, keyword, rval)
    ccall((:hputr4, libhashpipe), Cint, (Cstring, Cstring, Cfloat), hstring, keyword, rval)
end

function hputr8(hstring, keyword, dval)
    ccall((:hputr8, libhashpipe), Cint, (Cstring, Cstring, Cdouble), hstring, keyword, dval)
end

function hputnr8(hstring, keyword, ndec, dval)
    ccall((:hputnr8, libhashpipe), Cint, (Cstring, Cstring, Cint, Cdouble), hstring, keyword, ndec, dval)
end

function hputs(hstring, keyword, cval)
    ccall((:hputs, libhashpipe), Cint, (Cstring, Cstring, Cstring), hstring, keyword, cval)
end

function hputm(hstring, keyword, cval)
    ccall((:hputm, libhashpipe), Cint, (Cstring, Cstring, Cstring), hstring, keyword, cval)
end

function hputcom(hstring, keyword, comment)
    ccall((:hputcom, libhashpipe), Cint, (Cstring, Cstring, Cstring), hstring, keyword, comment)
end

function hputra(hstring, keyword, ra)
    ccall((:hputra, libhashpipe), Cint, (Cstring, Cstring, Cdouble), hstring, keyword, ra)
end

function hputdec(hstring, keyword, dec)
    ccall((:hputdec, libhashpipe), Cint, (Cstring, Cstring, Cdouble), hstring, keyword, dec)
end

function hputl(hstring, keyword, lval)
    ccall((:hputl, libhashpipe), Cint, (Cstring, Cstring, Cint), hstring, keyword, lval)
end

function hputc(hstring, keyword, cval)
    ccall((:hputc, libhashpipe), Cint, (Cstring, Cstring, Cstring), hstring, keyword, cval)
end

function hdel(hstring, keyword)
    ccall((:hdel, libhashpipe), Cint, (Cstring, Cstring), hstring, keyword)
end

function hadd(hplace, keyword)
    ccall((:hadd, libhashpipe), Cint, (Cstring, Cstring), hplace, keyword)
end

function hchange(hstring, keyword1, keyword2)
    ccall((:hchange, libhashpipe), Cint, (Cstring, Cstring, Cstring), hstring, keyword1, keyword2)
end

function ra2str(string, lstr, ra, ndec)
    ccall((:ra2str, libhashpipe), Cvoid, (Cstring, Cint, Cdouble, Cint), string, lstr, ra, ndec)
end

function dec2str(string, lstr, dec, ndec)
    ccall((:dec2str, libhashpipe), Cvoid, (Cstring, Cint, Cdouble, Cint), string, lstr, dec, ndec)
end

function deg2str(string, lstr, deg, ndec)
    ccall((:deg2str, libhashpipe), Cvoid, (Cstring, Cint, Cdouble, Cint), string, lstr, deg, ndec)
end

function num2str(string, num, field, ndec)
    ccall((:num2str, libhashpipe), Cvoid, (Cstring, Cdouble, Cint, Cint), string, num, field, ndec)
end

function setheadshrink(hsh)
    ccall((:setheadshrink, libhashpipe), Cvoid, (Cint,), hsh)
end

function setleaveblank(hsh)
    ccall((:setleaveblank, libhashpipe), Cvoid, (Cint,), hsh)
end
# Julia wrapper for header: hashpipe.h
# Automatically generated using Clang.jl


function run_threads()
    ccall((:run_threads, libhashpipe), Cint, ())
end

function get_cpu_affinity()
    ccall((:get_cpu_affinity, libhashpipe), UInt32, ())
end
# Julia wrapper for header: hashpipe_error.h
# Automatically generated using Clang.jl

