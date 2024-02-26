# Following Nakassis 1988, https://doi.org/10.1145/53644.53648

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

function fletcher32(data, fletcher::UInt32=0x00000000)
    len = length(data)

    c1 = UInt64((fletcher & 0xffff0000) >> 16)
    c0 = UInt64(fletcher & 0x0000ffff)

    # one byte at a time is annoying
    if len == 1
        c0 += data[1]
        c1 += c0
        c0 %= UInt64(0xffff)
        c1 %= UInt64(0xffff)
        return ((c1 << UInt64(16)) | c0) % UInt32
    end

    len == 0 && return UInt32(0)

    i = 1
    while len > 0
        # from solving the following:
        # n > 0
        # n * (n+1) / 2 * (2^16 - 1) < (2^32 - 1)
        # In 64 bits, we can cheat and use a way larger blocksize
        blocksize = min(len, 23726746)
        len -= blocksize
        @inbounds while blocksize > 0
            c0 += data[i] % UInt64
            c1 += c0
            i += 1
            blocksize -= 1
        end
        c0 %= UInt64(0xffff)
        c1 %= UInt64(0xffff)
    end
    return ((c1 << UInt64(16)) | c0) % UInt32
end

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