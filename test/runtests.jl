using SimpleChecksums

using Libz
using Random
using Test

@testset "Fletcher's Checksum" begin
    RNG = Random.MersenneTwister(42)

    # empty arrays add nothing
    init16 = rand(RNG, UInt16)
    @test fletcher_checksum(UInt16, [], init16) == init16
    @test fletcher16([], init16) == init16
    @test fletcher16a([], init16) == init16

    init32 = rand(RNG, UInt32)
    @test fletcher_checksum(UInt32, [], init32) == init32
    @test fletcher32([], init32) == init32
    @test fletcher32a([], init16) == init16

    init64 = rand(RNG, UInt64)
    @test fletcher_checksum(UInt64, [], init64) == init64
    @test fletcher64([], init64) == init64
    @test fletcher64a([], init64) == init64

    @test SimpleChecksums.adler32([], init32) == init32

    # known values from Wikipedia https://en.wikipedia.org/wiki/Fletcher's_checksum
    @test fletcher16(b"abcde") == 0xC8F0
    @test fletcher16(b"abcdef") == 0x2057
    @test fletcher16(b"abcdefgh") == 0x0627

    @test fletcher32(reinterpret(UInt16, Vector{UInt8}(b"abcde\0"))) == 0xF04FC729
    @test fletcher32(reinterpret(UInt16, Vector{UInt8}(b"abcdef"))) == 0x56502D2A
    @test fletcher32(reinterpret(UInt16, Vector{UInt8}(b"abcdefgh"))) == 0xEBE19591

    @test fletcher64(reinterpret(UInt32, Vector{UInt8}(b"abcde\0\0\0"))) == 0xC8C6C527646362C6
    @test fletcher64(reinterpret(UInt32, Vector{UInt8}(b"abcdef\0\0"))) == 0xC8C72B276463C8C6
    @test fletcher64(reinterpret(UInt32, Vector{UInt8}(b"abcdefgh"))) == 0x312E2B28CCCAC8C6

    # one byte at a time is the same as all at once
    rand100 = rand(RNG, UInt8, 100)
    cs16 = foldl((prev, val) -> fletcher16(val, prev), rand100, init=0x0000)
    @test cs16 == fletcher16(rand100)
    cs16a = foldl((prev, val) -> fletcher16a(val, prev), rand100, init=0x0000)
    @test cs16a == fletcher16a(rand100)

    cs32 = foldl((prev, val) -> fletcher32(val, prev), rand100, init=0x00000000)
    @test cs32 == fletcher32(rand100)
    cs32a = foldl((prev, val) -> fletcher32a(val, prev), rand100, init=0x00000000)
    @test cs32a == fletcher32a(rand100)

    cs64 = foldl((prev, val) -> fletcher64(val, prev), rand100, init=0x0000000000000000)
    @test cs64 == fletcher64(rand100)
    cs64a = foldl((prev, val) -> fletcher64a(val, prev), rand100, init=0x0000000000000000)
    @test cs64a == fletcher64a(rand100)

    # known implementation of adler32
    @test SimpleChecksums.adler32(rand100) == Libz.adler32(rand100)

    # one byte at a time is the same as all at once
    ad32 = foldl((prev, val) -> SimpleChecksums.adler32(val, prev), rand100, init=0x00000001)
    @test ad32 == SimpleChecksums.adler32(rand100)
end

@testset "Additive Checksum" begin
    RNG = Random.MersenneTwister(42)

    # empty arrays add nothing
    init16 = rand(RNG, UInt16)
    @test additive_checksum(UInt16, [], init16) == init16
    @test additive16([], init16) == init16

    init32 = rand(RNG, UInt32)
    @test additive_checksum(UInt32, [], init32) == init32
    @test additive32([], init32) == init32

    init64 = rand(RNG, UInt64)
    @test additive_checksum(UInt64, [], init64) == init64
    @test additive64([], init64) == init64

    # simple values
    @test additive16(b"abcde") == sum(b"abcde")
    @test additive16(b"abcdef") == sum(b"abcdef")
    @test additive16(b"abcdefgh") == sum(b"abcdefgh")


    # one byte at a time is the same as all at once
    rand100 = rand(RNG, UInt8, 100)
    cs16 = foldl((prev, val) -> additive16(val, prev), rand100, init=0x0000)
    @test cs16 == additive16(rand100)

    cs32 = foldl((prev, val) -> additive32(val, prev), rand100, init=0x00000000)
    @test cs32 == additive32(rand100)

    cs64 = foldl((prev, val) -> additive64(val, prev), rand100, init=0x0000000000000000)
    @test cs64 == additive64(rand100)
end

@testset "BSD Checksum" begin
    RNG = Random.MersenneTwister(42)

    # empty arrays add nothing
    init16 = rand(RNG, UInt16)
    @test bsd_checksum(UInt16, [], init16) == init16
    @test bsd16([], init16) == init16

    # known values from running GNU sum with -r switch
    @test bsd16(b"abcde") == 4290
    @test bsd16(b"abcdef") == 2247
    @test bsd16(b"abcdefgh") == 17101

    # one byte at a time is the same as all at once
    rand100 = rand(RNG, UInt8, 100)
    cs16 = foldl((prev, val) -> bsd16(val, prev), rand100, init=0x0000)
    @test cs16 == bsd16(rand100)
end

@testset "SYS-V Checksum" begin
    RNG = Random.MersenneTwister(42)

    # empty arrays add nothing
    init16 = rand(RNG, UInt16)
    @test sysv_checksum(UInt16, [], init16) == init16
    @test sysv16([], init16) == init16

    # known values from running GNU sum with -r switch
    @test sysv16(b"abcde") == 495
    @test sysv16(b"abcdef") == 597
    @test sysv16(b"abcdefgh") == 804

    # one byte at a time is the same as all at once
    rand100 = rand(RNG, UInt8, 100)
    cs16 = foldl((prev, val) -> sysv16(val, prev), rand100, init=0x0000)
    @test cs16 == sysv16(rand100)
end