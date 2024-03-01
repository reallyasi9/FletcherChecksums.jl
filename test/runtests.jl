using FletcherChecksums
using Test

@testset "FletcherChecksums.jl" begin
    # Write your tests here.
    @test FletcherChecksums._fletcher16(b"abcde") == 0xC8F0
    @test FletcherChecksums._fletcher16(b"abcdef") == 0x2057
    @test FletcherChecksums._fletcher16(b"abcdefgh") == 0x0627

    @test FletcherChecksums._fletcher32(reinterpret(UInt16, Vector{UInt8}(b"abcde\0"))) == 0xF04FC729
    @test FletcherChecksums._fletcher32(reinterpret(UInt16, Vector{UInt8}(b"abcdef"))) == 0x56502D2A
    @test FletcherChecksums._fletcher32(reinterpret(UInt16, Vector{UInt8}(b"abcdefgh"))) == 0xEBE19591

    @test FletcherChecksums._fletcher64(reinterpret(UInt32, Vector{UInt8}(b"abcde\0\0\0"))) == 0xC8C6C527646362C6
    @test FletcherChecksums._fletcher64(reinterpret(UInt32, Vector{UInt8}(b"abcdef\0\0"))) == 0xC8C72B276463C8C6
    @test FletcherChecksums._fletcher64(reinterpret(UInt32, Vector{UInt8}(b"abcdefgh"))) == 0x312E2B28CCCAC8C6
end
