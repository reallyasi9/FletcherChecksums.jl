using SimpleChecksums

using Libz
using Random
using Test

@testset "Fletcher Checksum" begin
    RNG = Random.MersenneTwister(42)

    init16 = rand(RNG, UInt16)
    @test fletcher_checksum(UInt16, [], init16) == init16
    @test fletcher16([], init16) == init16

    init32 = rand(RNG, UInt32)
    @test fletcher_checksum(UInt32, [], init32) == init32
    @test fletcher32([], init32) == init32

    init64 = rand(RNG, UInt64)
    @test fletcher_checksum(UInt64, [], init64) == init64
    @test fletcher64([], init64) == init64

    @test fletcher16(b"abcde") == 0xC8F0
    @test fletcher16(b"abcdef") == 0x2057
    @test fletcher16(b"abcdefgh") == 0x0627

    @test fletcher32(reinterpret(UInt16, Vector{UInt8}(b"abcde\0"))) == 0xF04FC729
    @test fletcher32(reinterpret(UInt16, Vector{UInt8}(b"abcdef"))) == 0x56502D2A
    @test fletcher32(reinterpret(UInt16, Vector{UInt8}(b"abcdefgh"))) == 0xEBE19591

    @test fletcher64(reinterpret(UInt32, Vector{UInt8}(b"abcde\0\0\0"))) == 0xC8C6C527646362C6
    @test fletcher64(reinterpret(UInt32, Vector{UInt8}(b"abcdef\0\0"))) == 0xC8C72B276463C8C6
    @test fletcher64(reinterpret(UInt32, Vector{UInt8}(b"abcdefgh"))) == 0x312E2B28CCCAC8C6

    # one byte at a time
    rand100 = rand(RNG, UInt8, 100)
    cs16 = 0x0000
    for val in rand100
        cs16 = fletcher16(val, cs16)
    end
    @test cs16 == fletcher16(rand100)

    cs32 = 0x00000000
    for val in rand100
        cs32 = fletcher32(val, cs32)
    end
    @test cs32 == fletcher32(rand100)

    cs64 = 0x0000000000000000
    for val in rand100
        cs64 = fletcher64(val, cs64)
    end
    @test cs64 == fletcher64(rand100)

    # check against known implementation of adler32
    @test SimpleChecksums.adler32(rand100) == Libz.adler32(rand100)

    # check one at a time
    ad32 = 0x00000001
    for val in rand100
        ad32 = adler32(val, ad32)
    end
    @test ad32 == SimpleChecksums.adler32(rand100)
end
