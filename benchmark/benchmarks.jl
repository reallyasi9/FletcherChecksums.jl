using BenchmarkTools
using Random
using Checksums

const SUITE = BenchmarkGroup()

SUITE["fletcher"] = BenchmarkGroup()
SUITE["adler"] = BenchmarkGroup()
SUITE["additive"] = BenchmarkGroup()
SUITE["bsd"] = BenchmarkGroup()
SUITE["sysv"] = BenchmarkGroup()

for n in 0:20
    testdata = rand(MersenneTwister(42), UInt8, 1<<n)
    for f in (fletcher16, fletcher32, fletcher64)
        SUITE["fletcher"][string(f), n] = @benchmarkable ($f)($testdata)
    end
    for f in (additive16, additive32, additive64)
        SUITE["additive"][string(f), n] = @benchmarkable ($f)($testdata)
    end
    SUITE["adler"]["adler32", n] = @benchmarkable adler32($testdata)
    SUITE["bsd"]["bsd16", n] = @benchmarkable bsd16($testdata)
    SUITE["sysv"]["sysv16", n] = @benchmarkable sysv16($testdata)
end