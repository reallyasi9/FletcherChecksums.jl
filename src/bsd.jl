# BSD checksum: bit rotate right by 1, then add

function bsd(C::Type{T}, data, init::T = zero(C)) where {T<:Unsigned}
    len = length(data)
    len == 0 && return init
    bits = sizeof(T) * 8
    c0 = UInt64(init)
    i = 1
    while len > 0
        c0 = (c0 >> 1) + ((c0 & 1) << (bits-1))
        c0 += data[i]
        c0 &= typemax(T)
        i += 1
        len -= 1
    end
    return c0 % T
end

bsd16(data, init::UInt16 = zero(UInt16)) = bsd(UInt16, data, init)
bsd32(data, init::UInt32 = zero(UInt32)) = bsd(UInt32, data, init)
bsd64(data, init::UInt64 = zero(UInt64)) = bsd(UInt64, data, init)