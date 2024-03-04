module Checksums

# https://burtleburtle.net/bob/hash/doobs.html

export AbstractChecksum

export FletcherChecksum, Fletcher16, Fletcher32, Fletcher64
export fletcher16, fletcher32, fletcher64

export Fletcher16a, Fletcher32a, Fletcher64a
export fletcher16a, fletcher32a, fletcher64a

export Adler32
export adler32

export additive_checksum, additive16, additive32, additive64
export bsd_checksum, bsd16

export update, value, reset

include("checksum.jl")
include("fletcher.jl")
include("bsd.jl")
include("additive.jl")
include("sysv.jl")

end
