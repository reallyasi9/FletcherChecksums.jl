# BSD checksum: bit rotate right by 1, then add
@inline bsd_rotate(init::UInt16, val) = bitrotate(init, -1) + (val % UInt16)

"""
    bsd_checksum(UInt16, data, init::UInt16 = zero(UInt16))

Compute a hash of `data` using the method defined in BSD's sum utility (and implemented in the GNU sum program).

The BSD checksum computes a 16-bit checksum value by bit-rotating the checksum value from the previous step to the right by 1 bit, then adding the next value from `data` and repeating. Sums are allowed to overflow, which resets the sum to zero.

This function is fast but suffers from many collisions. Flaws to keep in mind are:
1. zero values at the beginning of `data` do not affect the checksum value at all (unless the initial value is set to something other than zero); and
2. runs of zeros in `data` that are multiples of 16 in length do not affect the checksum value at all.

## Arguments
- `data`: A single `Unsigned` value or an iterator of values.
- `init::UInt16 = zero(UInt16)`: Optional starting value.

Predefined convenience function is `bsd16`.
"""
function bsd_checksum(::Type{UInt16}, data, init::Unsigned = zero(UInt16))
    length(data) == 0 && return init % UInt16
    return foldl(bsd_rotate, data, init=init % UInt16)
end

@inline bsd_checksum(::Type{UInt16}, data::Unsigned, init::Unsigned = zero(UInt16)) = bsd_rotate(init % UInt16, data)

"""
    bsd16(data, [init])

Alias of `bsd_checksum(UInt16, data, init)`.
"""
bsd16(data, init::Unsigned = zero(UInt16)) = bsd_checksum(UInt16, data, UInt16(init))