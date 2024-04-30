# Described in Fletcher 1982, doi:10.1109/tcom.1982.1095369.
# Optimized following Nakassis 1988, doi:10.1145/53644.53648.

@inline split_fletcher(value::T) where {T <: Unsigned} = (UInt64(value >> (sizeof(T)*4)), UInt64(value & (typemax(T) >> (sizeof(T) * 4))))
@inline combine_fletcher(::Type{T}, c1::UInt64, c0::UInt64) where {T <: Unsigned} = T((c0 & (typemax(T) >> (sizeof(T)*4))) | (typemax(T) & (c1 << (sizeof(T)*4))))

"""
    fletcher_checksum(T, data, init::T = zero(T), modulo::T = typemax(T), blocksize::Integer = 1)

Compute a hash of `data` using Fletcher's checksum.

Fletcher's checksum computes two values: `c0`, a running sum of values modulo some number, and `c1`, a running sum of `c0` values modulo some number. The two values are contatenated bitwise into a single unsigned integer.

This function is fast and good at detecting small errors. Flaws to keep in mind are:
1. zero values at the beginning of `data` do not affect the checksum value at all (unless the initial value is set to something other than zero); and
2. the worst-case performance for this algorithm occurs when data are truly random, but all errors of up to 2 bits are detected on all runs of data of length `modulo * (sizeof(T)*4)` bits.

## Arguments
- `T`: An unsinged integer type.
- `data`: A single `Unsigned` value or an iterator of values.
- `init::Unsigned = zero(T)`: Optional starting value.
- `modulo::T = typemax(T)`: Optional modulo value, applied independently to the sum and the sum-of-sums after each block is summed.
- `blocksize::Integer = 1`: Optional block size for summing before applying the modulo operation. `blocksize` should be chosen with `modulo`, `T`, and `eltype(data)` in mind to make sure the sum operation does not overflow.

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

"""
    fletcher16(data, [init, modulo])

Alias of `fletcher_checksum(UInt16, data, init, modulo=0x00ff, blocksize=380368696)`.
"""
fletcher16(data, init::Unsigned = zero(UInt16)) = fletcher_checksum(UInt16, data, UInt16(init), 0x00ff, 380368696)

"""
    fletcher32(data, [init, modulo])

Alias of `fletcher_checksum(UInt32, data, init, modulo=0x0000ffff, blocksize=23726746)`.
"""
fletcher32(data, init::Unsigned = zero(UInt32)) = fletcher_checksum(UInt32, data, UInt32(init), 0x0000ffff, 23726746)

"""
    fletcher64(data, [init, modulo])

Alias of `fletcher_checksum(UInt64, data, init, modulo=0x00000000ffffffff, blocksize=92681)`.
"""
fletcher64(data, init::Unsigned = zero(UInt64)) = fletcher_checksum(UInt64, data, UInt64(init), 0x00000000ffffffff, 92681)

"""
    fletcher16a(data, [init, modulo])

Alias of `fletcher_checksum(UInt16, data, init, modulo=0x0100, blocksize=379625061)`.
"""
fletcher16a(data, init::Unsigned = zero(UInt16)) = fletcher_checksum(UInt16, data, UInt16(init), 0x0100, 379625061)

"""
    fletcher32a(data, [init, modulo])

Alias of `fletcher_checksum(UInt32, data, init, modulo=0x00010000, blocksize=23726565)`.
"""
fletcher32a(data, init::Unsigned = zero(UInt32)) = fletcher_checksum(UInt32, data, UInt32(init), 0x00010000, 23726565)

"""
    fletcher64a(data, [init, modulo])

Alias of `fletcher_checksum(UInt64, data, init, modulo=0x0000000100000000, blocksize=92681)`.
"""
fletcher64a(data, init::Unsigned = zero(UInt64)) = fletcher_checksum(UInt64, data, UInt64(init), 0x0000000100000000, 92681)

# adler32 is not optimized like the zlib version, but on modern hardware the Julia version has a runtime of anywhere between 90% and 110% of the zlib version.
"""
    adler32(data, init::Unsigned = one(UInt32))

Compute Adler's 32-bit checksum.

Adler's 32-bit checksum is the same as Fletcher's 32-bit checksum with a modulus of 65521 (the largest 16-bit prime) and an inital value of one. This is a strict improvement on `fletcher16`, but has a higher probability of collision, worse likelihood of error detection, and is slower than `fletcher32`. Prefer `fletcher32` instead.
"""
adler32(data, init::Unsigned = one(UInt32)) = fletcher_checksum(UInt32, data, UInt32(init), UInt32(65521), 5552)
