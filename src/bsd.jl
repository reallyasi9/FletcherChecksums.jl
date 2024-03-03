# BSD checksum: bit rotate right by 1, then add

function bsd(::Type{UInt16}, data, init::UInt16 = zero(UInt16))
    len = length(data)
    len == 0 && return init
    c0 = UInt32(init)
    i = 1
    while len > 0
        c0 = (c0 >> 1) + ((c0 & 1) << (15))
        c0 += data[i]
        c0 &= typemax(UInt16)
        i += 1
        len -= 1
    end
    return c0 % UInt16
end

bsd16(data, init::UInt16 = zero(UInt16)) = bsd(UInt16, data, init)