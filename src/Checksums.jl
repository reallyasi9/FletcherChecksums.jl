module Checksums

# https://burtleburtle.net/bob/hash/doobs.html

export Checksum

export additive
export bsd, bsd16
export sysv, sysv16
export Fletcher, Fletcher16, Fletcher32, Fletcher64
export fletcher16, fletcher32, fletcher64
export Fletcher16a, Fletcher32a, Fletcher64a
export fletcher16a, fletcher32a, fletcher64a
export Adler32
export adler32

export update, value, reset

include("checksum.jl")
include("fletcher.jl")
include("bsd.jl")
include("additive.jl")
include("sysv.jl")

end
