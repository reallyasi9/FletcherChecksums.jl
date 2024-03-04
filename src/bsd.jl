# BSD checksum: bit rotate right by 1, then add
function bsd_checksum(::Type{UInt16}, data, init::UInt16 = zero(UInt16))
    for x in data
        init = bitrotate(init, -1) + (x % UInt16)
    end
    return init
end

bsd_checksum(::Type{UInt16}, data::UInt8, init::UInt16 = zero(UInt16)) = bitrotate(init, -1) + (data % UInt16)
bsd16(data, init::Integer = zero(UInt16)) = bsd_checksum(UInt16, data, UInt16(init))