module SimpleChecksums

# https://burtleburtle.net/bob/hash/doobs.html

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

end
