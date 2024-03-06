# BSD checksum: bit rotate right by 1, then add
@inline bsd_rotate(init::UInt16, val) = bitrotate(init, -1) + (val % UInt16)
function bsd_checksum(::Type{UInt16}, data, init::UInt16 = zero(UInt16))
    length(data) == 0 && return init
    return foldl(bsd_rotate, data, init=init)
end

@inline bsd_checksum(::Type{UInt16}, data::UInt8, init::UInt16 = zero(UInt16)) = bsd_rotate(init, data)

bsd16(data, init::Integer = zero(UInt16)) = bsd_checksum(UInt16, data, UInt16(init))