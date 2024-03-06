# SYSV checksum: sum, then fold bits
@inline sysv_fold(r::UInt32) = (r & typemax(UInt16)) + (r >> 16)
@inline sysv_fold2(r::UInt32) = sysv_fold(sysv_fold(r))
function sysv_checksum(::Type{UInt16}, data, init::UInt16 = zero(UInt16))
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

function sysv_checksum(::Type{UInt16}, data::UInt8, init::UInt16 = zero(UInt16))
    r = (init % UInt32) + (data % UInt32)
    # Guaranteed to only need one fold
    r = sysv_fold(r)
    return UInt16(r)
end

sysv16(data, init::Integer = zero(UInt16)) = sysv_checksum(UInt16, data, init)