# Described in Fletcher 1982, doi:10.1109/tcom.1982.1095369.
# Optimized following Nakassis 1988, doi:10.1145/53644.53648.

@inline split_fletcher(value::T) where {T <: Unsigned} = (UInt64(value >> (sizeof(T)*4)), UInt64(value & (typemax(T) >> (sizeof(T) * 4))))
@inline combine_fletcher(::Type{T}, c1::UInt64, c0::UInt64) where {T <: Unsigned} = T((c0 & (typemax(T) >> (sizeof(T)*4))) | (c1 << (sizeof(T)*4)))

"""
    fletcher_checksum(T, data, init::T = zero(T), modulo::T = typemax(T), blocksize::Integer = 1)

Compute a hash of `data` using Fletcher's checksum .

The BSD checksum computes a 16-bit checksum value by bit-rotating the checksum value from the previous step to the right by 1 bit, then adding the next value from `data` and repeating. Sums are allowed to overflow, which resets the sum to zero.

This function is fast but suffers from many collisions. Flaws to keep in mind are:
1. zero values at the beginning of `data` do not affect the checksum value at all (unless the initial value is set to something other than zero); and
2. runs of zeros in `data` that are multiples of 16 in length do not affect the checksum value at all.

## Arguments
- `T`: An unsinged integer type.
- `data`: A single `Unsigned` value or an iterator of values.
- `init::Unsigned = zero(T)`: Optional starting value.
- `modulo::T = typemax(T)`: Optional modulo value, applied independently to the sum and the sum-of-sums after each block is summed.
- `blocksize::Integer = 1`: Optional block size for summing before applying the modulo operation.

Predefined convenience functions are `fletcher16`, `fletcher32`, and `fletcher64` for the standard modulo value of `typemax(T)` shifted right half the number of bits in the checksum, and `fletcher16a`, `fletcher32a`, and `fletcher64a` for the alternate modulo value of `1` left shifted half the number of bits in the checksum.

See also: [adler32](@ref).
"""

function fletcher_checksum(::Type{T}, data, init::Unsigned = zero(T), modulo::T = typemax(T), blocksize::Integer = 1) where {T <: Unsigned}
    len = length(data)
    len == 0 && return init % T
    len == 1 && return fletcher_checksum(T, first(data), init, modulo, blocksize)

    c1, c0 = split_fletcher(init % T)

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

function fletcher_checksum(::Type{T}, data::Unsigned, init::Unsigned = zero(T), modulo::T = typemax(T), blocksize::Integer = 1) where {T <: Unsigned}
    c1, c0 = split_fletcher(init % T)

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

fletcher16(data, init::Unsigned = zero(UInt16)) = fletcher_checksum(UInt16, data, UInt16(init), 0x00ff, 380368696)
fletcher32(data, init::Unsigned = zero(UInt32)) = fletcher_checksum(UInt32, data, UInt32(init), 0x0000ffff, 23726746)
fletcher64(data, init::Unsigned = zero(UInt64)) = fletcher_checksum(UInt64, data, UInt64(init), 0x00000000ffffffff, 92681)

fletcher16a(data, init::Unsigned = zero(UInt16)) = fletcher_checksum(UInt16, data, UInt16(init), 0x0100, 379625061)
fletcher32a(data, init::Unsigned = zero(UInt32)) = fletcher_checksum(UInt32, data, UInt32(init), 0x00010000, 23726565)
fletcher64a(data, init::Unsigned = zero(UInt64)) = fletcher_checksum(UInt64, data, UInt64(init), 0x0000000100000000, 92681)

# adler32 is not optimized like the zlib version, but on modern hardware the Julia version has a runtime of anywhere between 90% and 110% of the zlib version.
adler32(data, init::Unsigned = one(UInt32)) = fletcher_checksum(UInt32, data, UInt32(init), UInt32(65521), 5552)
