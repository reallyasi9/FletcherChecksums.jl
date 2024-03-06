```@meta
CurrentModule = SimpleChecksums
```

# SimpleChecksums

Documentation for [SimpleChecksums](https://github.com/reallyasi9/SimpleChecksums.jl).

```@index
```

## Synopsis

### Installation

```julia
using Pkg
Pkg.add("SimpleChecksums")
```

### Use

```julia
using SimpleChecksums

data = UInt8.(0:255);

# super-simple sums:
@assert additive_checksum(UInt16, data) == additive16(data) == 0x7f80
@assert additive_checksum(UInt32, data) == additive32(data) == 0x00007f80
@assert additive_checksum(UInt64, data) == additive64(data) == 0x0000000000007f80

# BSD and SYS-V checksums from GNU sum utility:
@assert bsd_checksum(UInt16, data) == bsd16(data) == 0x0200
@assert sysv_checksum(UInt16, data) == sysv16(data) == 0x7f80

# Fletcher's and Adler's checksums:
@assert fletcher_checksum(UInt16, data) == fletcher16(data) == 0x5500
@assert fletcher_checksum(UInt32, data) == fletcher32(data) == 0xaaaa7f80
@assert fletcher_checksum(UInt64, data) == fletcher64(data) == 0x002aaa8000007f80

@assert fletcher_checksum(UInt16, data, UInt16(0), 0x100) == fletcher16a(data) == 0x8080
@assert fletcher_checksum(UInt32, data, UInt32(0), 0x10000) == fletcher32a(data) == 0xaa807f80
@assert fletcher_checksum(UInt64, data, UInt64(0), 0x100000000) == fletcher64a(data) == 0x002aaa8000007f80

@assert fletcher_checksum(UInt32, data, UInt32(1), UInt32(65521), 5552) == adler32(data) == 0xadf67f81
```

## Why?

Checksums are small summaries of data that can be used to detect errors introduced to the data during transmission or storage. In modern times, checksums have largely been replaced with cryptographic hashes like [MD5](https://github.com/JuliaCrypto/MD5.jl) and [SHA](https://docs.julialang.org/en/v1/stdlib/SHA/), but these functions and the computational power required to compute them in a reasonable amount of time did not exist when many of the data transmission and storage standards we use today were invented. If we want to use the checksums that appear in these standards in Julia code, it helps to have a standard library to compute them correctly and efficiently.

If you are building a new data transmission or storage standard and need a way to check for errors, consider using a cryptographic hash like [SHA](https://docs.julialang.org/en/v1/stdlib/SHA/), or at least a better error-detecting code like [CRC](https://github.com/JuliaIO/CRC32.jl), before choosing any of these functions.

## API

```@autodocs
Modules = [SimpleChecksums]
```
