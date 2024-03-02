# Unoptimized generic function

function fletcher(C::Type{T}, data, init::T = zero(C), modulo::T = typemax(C) >> (sizeof(C)*4)) where {T<:Unsigned}
    len = length(data)
    len == 0 && return init

    c1 = (init >> (sizeof(T)*4)) % T
    c0 = (typemax(T) >> (sizeof(T)*4)) % T

    i = 1
    @inbounds while len > 0
        c0 += data[i] % T
        c0 %= modulo
        c1 += c0
        c1 %= modulo
        i += 1
        len -= 1
    end

    T(c0 | (c1 << (sizeof(T)*4)))
end

# Optimized following Nakassis 1988, https://doi.org/10.1145/53644.53648

function _fletcher(C::Type{<:Unsigned}, data, c0::T, modulo::T, blocksize::Int) where {T<:Unsigned}
    len = length(data)
    len == 0 && return c0 % C

    c1 = T(c0 >> (sizeof(C)*4))
    c0 %= T(typemax(C) >> (sizeof(C)*4))

    # one byte at a time is annoying
    if len == 1
        @inbounds c0 += data[1] % T
        if c0 > modulo
            c0 -= modulo
        end
        c1 += c0
        if c1 > modulo
            c1 -= modulo
        end
        return C(c0 | (c1 << T(sizeof(C)*4)))
    end

    i = 1
    @inbounds while len > blocksize
        len -= blocksize
        n = blocksize
        while n > 0
            c0 += data[i] % T
            c1 += c0
            i += 1
            n -= 1
        end
        c0 %= modulo
        c1 %= modulo
    end

    if len > 0
        @inbounds while len > 0
            c0 += data[i] % T
            c1 += c0
            len -= 1
            i += 1
        end
        c0 %= modulo
        c1 %= modulo
    end

    return C(c0 | (c1 << T(sizeof(C)*4)))
end

# 16 and 32 cheat by using another blocksize solution to the overflow equation that fits in a 64-bit int
fletcher16(data, init::UInt16 = zero(UInt16)) = _fletcher(UInt16, data, UInt64(init), UInt64(0xff), 380368696)
fletcher32(data, init::UInt32 = zero(UInt32)) = _fletcher(UInt32, data, UInt64(init), UInt64(0xffff), 23726746)
fletcher64(data, init::UInt64 = zero(UInt64)) = _fletcher(UInt64, data, init, UInt64(0xffffffff), 92681)

# alternate versions use slightly different modulos (meaning slightly different block sizes as well)
fletcher16a(data, init::UInt16 = zero(UInt16)) = _fletcher(UInt16, data, UInt64(init), UInt64(0x100), 379625061)
fletcher32a(data, init::UInt32 = zero(UInt32)) = _fletcher(UInt32, data, UInt64(init), UInt64(0x10000), 23726565)
fletcher64a(data, init::UInt64 = zero(UInt64)) = _fletcher(UInt64, data, init, UInt64(0x100000000), 92681)

# adler32 is not optimized, but on modern hardware you barely see a difference
adler32(data, init::UInt32 = one(UInt32)) = _fletcher(UInt32, data, init, UInt32(65521), 5552)