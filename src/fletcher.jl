# Optimized following Nakassis 1988, https://doi.org/10.1145/53644.53648

@inline function value(cs::FletcherChecksum{T}) where {T}
    return ((cs.c0 & (typemax(T) >> (sizeof(T)*4))) | (cs.c1 << (sizeof(T)*4))) % T
end

function fletcher(::Type{T}, init::T = zero(T), modulo::T = typemax(T), blocksize::T = one(T)) where {T <: Unsigned}
    len = length(data)
    len == 0 && return cs
    len == 1 && return update(cs, data[begin])

    i = 1
    c0 = cs.c0
    c1 = cs.c1
    @inbounds while len > cs.blocksize
        len -= cs.blocksize
        n = cs.blocksize
        while n > 0
            c0 += data[i]
            c1 += c0
            i += 1
            n -= 1
        end
        c0 %= cs.modulo
        c1 %= cs.modulo
    end

    if len > 0
        @inbounds while len > 0
            c0 += data[i]
            c1 += c0
            len -= 1
            i += 1
        end
        c0 %= cs.modulo
        c1 %= cs.modulo
    end

    return FletcherChecksum{T}(c0, c1, cs.modulo, cs.blocksize)
end

function update(cs::FletcherChecksum{T}, value::UInt8) where {T}
    c0 = cs.c0 + value
    if c0 > cs.modulo
        c0 -= cs.modulo
    end
    c1 = c0 + cs.c1
    if c1 > cs.modulo
        c1 -= cs.modulo
    end
    return FletcherChecksum{T}(c0, c1, cs.modulo, cs.blocksize)
end

function Fletcher16(init::UInt16 = zero(UInt16))
    c1 = init >> 8
    c0 = init & 0xff
    return FletcherChecksum{UInt16}(c0, c1, UInt64(0xff), 380368696)
end

function Fletcher32(init::UInt32 = zero(UInt32))
    c1 = init >> 16
    c0 = init & 0xffff
    return FletcherChecksum{UInt32}(c0, c1, UInt64(0xffff), 23726746)
end

function Fletcher64(init::UInt64 = zero(UInt64))
    c1 = init >> 32
    c0 = init & 0xffffffff
    return FletcherChecksum{UInt64}(c0, c1, UInt64(0xffffffff), 92681)
end

function Fletcher16a(init::UInt16 = zero(UInt16))
    c1 = init >> 8
    c0 = init & 0xff
    return FletcherChecksum{UInt16}(c0, c1, UInt64(0x100), 379625061)
end

function Fletcher32a(init::UInt32 = zero(UInt32))
    c1 = init >> 16
    c0 = init & 0xffff
    return FletcherChecksum{UInt32}(c0, c1, UInt64(0x10000), 23726565)
end

function Fletcher64a(init::UInt64 = zero(UInt64))
    c1 = init >> 32
    c0 = init & 0xffffffff
    return FletcherChecksum{UInt64}(c0, c1, UInt64(0x100000000), 92681)
end

# 16 and 32 cheat by using another blocksize solution to the overflow equation that fits in a 64-bit int
fletcher16(data, init::UInt16 = zero(UInt16)) = value(update(Fletcher16(init), data))
fletcher32(data, init::UInt32 = zero(UInt32)) = value(update(Fletcher32(init), data))
fletcher64(data, init::UInt64 = zero(UInt64)) = value(update(Fletcher64(init), data))

# alternate versions use slightly different modulos (meaning slightly different block sizes as well)
fletcher16a(data, init::UInt16 = zero(UInt16)) = value(update(Fletcher16a(init), data))
fletcher32a(data, init::UInt32 = zero(UInt32)) = value(update(Fletcher32a(init), data))
fletcher64a(data, init::UInt64 = zero(UInt64)) = value(update(Fletcher64a(init), data))

# adler32 is not optimized, but on modern hardware you barely see a difference
function Adler32(init::UInt32 = one(UInt32))
    c1 = init >> 16
    c0 = init & 0xffff
    return FletcherChecksum{UInt32}(c0, c1, UInt64(65521), 5552)
end

adler32(data, init::UInt32 = one(UInt32)) = value(update(Adler32(init), data))
