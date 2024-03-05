# Optimized following Nakassis 1988, https://doi.org/10.1145/53644.53648

@inline split_fletcher(value::T) where {T <: Unsigned} = (UInt64(value >> (sizeof(T)*4)), UInt64(value & (typemax(T) >> (sizeof(T) * 4))))
@inline combine_fletcher(::Type{T}, c1::UInt64, c0::UInt64) where {T <: Unsigned} = T((c0 & (typemax(T) >> (sizeof(T)*4))) | (c1 << (sizeof(T)*4)))

function fletcher_checksum(::Type{T}, data, init::T = zero(T), modulo::T = typemax(T), blocksize::Integer = 1) where {T <: Unsigned}
    len = length(data)
    len == 0 && return init
    len == 1 && return fletcher_checksum(T, first(data), init, modulo, blocksize)

    c1, c0 = split_fletcher(init)

    for block in Iterators.partition(data, blocksize)
        for x in block
            c0 += x % UInt64
            c1 += c0
        end
        c0 %= modulo
        c1 %= modulo
    end
    return combine_fletcher(T, c1, c0)
end

function fletcher_checksum(::Type{T}, data::UInt8, init::T = zero(T), modulo::T = typemax(T), blocksize::Integer = 1) where {T <: Unsigned}
    c1, c0 = split_fletcher(init)

    c0 += data
    if c0 >= modulo
        c0 -= modulo
    end
    c1 += c0
    if c1 >= modulo
        c1 -= modulo
    end

    return combine_fletcher(T, c1, c0)
end

fletcher16(data, init::Integer = zero(UInt16)) = fletcher_checksum(UInt16, data, UInt16(init), 0x00ff, 380368696)
fletcher32(data, init::Integer = zero(UInt32)) = fletcher_checksum(UInt32, data, UInt32(init), 0x0000ffff, 23726746)
fletcher64(data, init::Integer = zero(UInt64)) = fletcher_checksum(UInt64, data, UInt64(init), 0x00000000ffffffff, 92681)

fletcher16a(data, init::Integer = zero(UInt16)) = fletcher_checksum(UInt16, data, UInt16(init), 0x0100, 379625061)
fletcher32a(data, init::Integer = zero(UInt32)) = fletcher_checksum(UInt32, data, UInt32(init), 0x00010000, 23726565)
fletcher64a(data, init::Integer = zero(UInt64)) = fletcher_checksum(UInt64, data, UInt64(init), 0x0000000100000000, 92681)

# adler32 is not optimized like the zlib version, but on modern hardware the Julia version has a runtime of about 110% of the zlib version.
adler32(data, init::Integer = one(UInt32)) = fletcher_checksum(UInt32, data, UInt32(init), UInt32(65521), 5552)
