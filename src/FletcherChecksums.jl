module FletcherChecksums

export fletcher16, fletcher32, fletcher64
export adler32

include("fletcher.jl")
include("adler.jl")

end
