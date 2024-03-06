module SimpleChecksums

using PrecompileTools

export fletcher_checksum
export fletcher16, fletcher32, fletcher64
export fletcher16a, fletcher32a, fletcher64a
export adler32

export additive_checksum, additive16, additive32, additive64
export bsd_checksum, bsd16
export sysv_checksum, sysv16

include("fletcher.jl")
include("bsd.jl")
include("additive.jl")
include("sysv.jl")

@compile_workload begin
    fletcher16(one(UInt8))
    fletcher32(one(UInt8))
    fletcher64(one(UInt8))
    fletcher16(UInt8[1,2])
    fletcher32(UInt8[1,2])
    fletcher64(UInt8[1,2])

    additive16(one(UInt8))
    additive32(one(UInt8))
    additive64(one(UInt8))
    additive16(UInt8[1,2])
    additive32(UInt8[1,2])
    additive64(UInt8[1,2])

    bsd16(one(UInt8))
    bsd16(UInt8[1,2])
    sysv16(one(UInt8))
    sysv16(UInt8[1,2])
end

end
