# Following Nakassis 1988, https://doi.org/10.1145/53644.53648

function _fletcher(data, val::T, base::C, nmax::C) where {T<:Unsigned,C<:Unsigned}
    @assert sizeof(C) >= sizeof(T)

    len = length(data)
    # optimize for nothing
    len == 0 && return val

    halfwidth = sizeof(T)*4
    halfmask = typemax(T)>>halfwidth
    c1 = C(val >> halfwidth)
    val &= halfmask

    # optimize for single element
    if len == 1
        @inbounds val += data[1]
        if val > base
            val -= base
        end
        c1 += val
        if c1 > base
            c1 -= base
        end
        return val | (c1 << halfwidth) % T
    end

    # guaranteed to not overflow
    i = 1
    while len > base
        len -= base
        n = base
        @inbounds while n > 0
            val += data[i] % T
            c1 += val
            i += 1
            n -= 1
        end
        val %= nmax
        c1 %= nmax
    end

    # also guaranteed to not overflow
    if len > 0
        @inbounds while len > 0
            len -= 1
            val += data[i] % T
            c1 += val
            i += 1
        end
        val %= nmax
        c1 %= nmax
    end
    return val | (c1 << halfwidth) % T
end

_fletcher16(data, val::UInt16=zero(UInt16)) = _fletcher(data, val, UInt16(5802), UInt16(0xff))
_fletcher32(data, val::UInt32=zero(UInt32)) = _fletcher(data, val, UInt64(23726746), UInt64(0xffff))
_fletcher64(data, val::UInt64=zero(UInt64)) = _fletcher(data, val, UInt64(92681), UInt64(0xffffffff))

const BASE16 = 5802
const NMAX16 = UInt16(0xff)

function fletcher16(data, fletcher::UInt16=0x0000)
    len = length(data)

    c1 = UInt16((fletcher & 0xff00) >> 8)
    c0 = UInt16(fletcher & 0x00ff)

    # one byte at a time is annoying
    if len == 1
        @inbounds c0 += data[1]
        c1 += c0
        c0 %= NMAX16
        c1 %= NMAX16
        return (c1 << UInt16(8)) | c0
    end

    len == 0 && return UInt16(0)
    
    i = 1
    while len > BASE16
        len -= BASE16
        n = BASE16
        @inbounds while n > 0
            c0 += data[i] % UInt16
            c1 += c0
            i += 1
            n -= 1
        end
        c0 %= NMAX16
        c1 %= NMAX16
    end
    if len > 0
        @inbounds while len > 0
            len -= 1
            c0 += data[i] % UInt16
            c1 += c0
            i += 1
        end
        c0 %= NMAX16
        c1 %= NMAX16
    end
    return (c1 << UInt16(8)) | c0
end

const BASE32 = 23726746
const NMAX32 = UInt64(0xffff)

function fletcher32(data, fletcher::UInt32=0x00000000)
    len = length(data)

    c1 = UInt64((fletcher & 0xffff0000) >> 16)
    c0 = UInt64(fletcher & 0x0000ffff)

    # one byte at a time is annoying
    if len == 1
        c0 += data[1]
        c1 += c0
        c0 %= NMAX32
        c1 %= NMAX32
        return ((c1 << UInt64(16)) | c0) % UInt32
    end

    len == 0 && return UInt32(0)

    i = 1
    while len > BASE32
        len -= BASE32
        n = BASE32
        @inbounds while n > 0
            c0 += data[i] % UInt64
            c1 += c0
            i += 1
            n -= 1
        end
        c0 %= NMAX32
        c1 %= NMAX32
    end
    if len > 0
        @inbounds while len > 0
            len -= 1
            c0 += data[i] % UInt64
            c1 += c0
            i += 1
        end
        c0 %= NMAX32
        c1 %= NMAX32
    end
    return ((c1 << UInt64(16)) | c0) % UInt32
end

const BASE64 = 92681
const NMAX64 = UInt64(0xffffffff)

function fletcher64(data, fletcher::UInt64=0x0000000000000000)
    len = length(data)

    c1 = UInt64((fletcher & 0xffffffff00000000) >> 32)
    c0 = UInt64(fletcher & 0x00000000ffffffff)

    # one byte at a time is annoying
    if len == 1
        c0 += data[1]
        c1 += c0
        c0 %= UInt64(0xffffffff)
        c1 %= UInt64(0xffffffff)
        return ((c1 << UInt64(32)) | c0) % UInt64
    end

    len == 0 && return UInt64(0)

    i = 1
    while len > 0
        # from solving the following:
        # n > 0
        # n * (n+1) / 2 * (2^32 - 1) < (2^64 - 1)
        blocksize = min(len, 92681)
        len -= blocksize
        @inbounds while blocksize > 0
            c0 += data[i] % UInt64
            c1 += c0
            i += 1
            blocksize -= 1
        end
        c0 %= UInt64(0xffffffff)
        c1 %= UInt64(0xffffffff)
    end
    return ((c1 << UInt64(32)) | c0) % UInt64
end