# SYSV checksum: sum, then fold bits
@inline sysv_fold(r::UInt32) = (r & typemax(UInt16)) + (r >> 16)
@inline sysv_fold2(r::UInt32) = sysv_fold(sysv_fold(r))

"""
    sysv_checksum(UInt16, data, init::UInt16 = zero(UInt16))

Compute a hash of `data` using the method defined in SYS-V's sum utility (and implemented in the GNU sum program).

The SYS-V checksum computes a 16-bit checksum value using a simple 32-bit additive sum, then folding the sum into a 16-bit number by adding the low 16 bits to the high 16 bits (shifted right by 16 bits). This fold is performed twice to guarantee the result is a 16-bit number. Unlike the SYS-V and GNU implementations, the sum in this implementation is allowed to overflow, which resets the sum to zero (SYS-V and GNU will raise an error instead).

This function is very fast but suffers from many collisions. Flaws to keep in mind are:
1. zero values anywhere in `data` do not affect the checksum value at all (unless the initial value is set to something other than zero); and
2. the order of the data can be permuted without affecting the checksum value.

## Arguments
- `data`: A single `Unsigned` value or an iterator of values.
- `init::UInt16 = zero(UInt16)`: Optional starting value.

Predefined convenience function is `sysv16`.

See also: `additive16`.
"""
function sysv_checksum(::Type{UInt16}, data, init::Unsigned = zero(UInt16))
    length(data) == 0 && return init
    length(data) == 1 && return sysv_checksum(UInt16, first(data), init)
    # This is about twice as fast as sum(data) because it forces UInt32 instead of converting to UInt64
    r = (init % UInt32) + mapreduce(UInt32, +, data)
    # In the SYS-V checksum, the fold is done twice to make sure r fits into 16 bits.
    # The worst-case scenario is sum(data) == typemax(UInt32), in which case:
    # 1. r = 0xffffffff -> 0x0000ffff + 0x0000ffff = 0x0001fffe
    # 2. r = 0x0001fffe -> 0x0000fffe + 0x00000001 = 0x0000ffff
    r = sysv_fold2(r)
    return UInt16(r)
end

function sysv_checksum(::Type{UInt16}, data::Unsigned, init::Unsigned = zero(UInt16))
    r = (init % UInt32) + (data % UInt32)
    # Guaranteed to only need one fold
    r = sysv_fold(r)
    return UInt16(r)
end

sysv16(data, init::Unsigned = zero(UInt16)) = sysv_checksum(UInt16, data, init)