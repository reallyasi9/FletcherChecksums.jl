const BASE = UInt32(65521)
const NMAX = UInt32(5552)

function adler32(data, adler::UInt32=0x00000001)
    sum2 = (adler >> 16) & 0xffff
    adler &= 0xffff

    len = length(data)

    if len == 1
        @inbounds adler += data[1]
        if adler > BASE 
            adler -= BASE
        end
        sum2 += adler
        if sum2 > BASE
            sum2 -= BASE
        end
        return adler | (sum2 << 16) % UInt32
    end

    len == 0 && return UInt32(1)

    if len < 16
        i = 1
        @inbounds while len > 0
            adler += data[i]
            sum2 += adler
            len -= 1
            i += 1
        end
        if adler > BASE
            adler -= BASE
        end
        sum2 %= BASE
        return adler | (sum2 << 16) % UInt32
    end

    i = 1
    @inbounds while len >= NMAX
        len -= NMAX
        n = (NMAX>>4) % UInt32
        while n > 0
            # unrolled 16 adds for speed
            adler += data[i]
            sum2 += adler
            adler += data[i+1]
            sum2 += adler
            adler += data[i+2]
            sum2 += adler
            adler += data[i+3]
            sum2 += adler
            adler += data[i+4]
            sum2 += adler
            adler += data[i+5]
            sum2 += adler
            adler += data[i+6]
            sum2 += adler
            adler += data[i+7]
            sum2 += adler
            adler += data[i+8]
            sum2 += adler
            adler += data[i+9]
            sum2 += adler
            adler += data[i+10]
            sum2 += adler
            adler += data[i+11]
            sum2 += adler
            adler += data[i+12]
            sum2 += adler
            adler += data[i+13]
            sum2 += adler
            adler += data[i+14]
            sum2 += adler
            adler += data[i+15]
            sum2 += adler
            n -= UInt32(1)
            i += 16
        end
        adler %= BASE
        sum2 %= BASE
    end

    if len > 0
        # do the rest in blocks of 16 until we run out
        @inbounds while len >= 16
            # unrolled 16 adds for speed
            adler += data[i]
            sum2 += adler
            adler += data[i+1]
            sum2 += adler
            adler += data[i+2]
            sum2 += adler
            adler += data[i+3]
            sum2 += adler
            adler += data[i+4]
            sum2 += adler
            adler += data[i+5]
            sum2 += adler
            adler += data[i+6]
            sum2 += adler
            adler += data[i+7]
            sum2 += adler
            adler += data[i+8]
            sum2 += adler
            adler += data[i+9]
            sum2 += adler
            adler += data[i+10]
            sum2 += adler
            adler += data[i+11]
            sum2 += adler
            adler += data[i+12]
            sum2 += adler
            adler += data[i+13]
            sum2 += adler
            adler += data[i+14]
            sum2 += adler
            adler += data[i+15]
            sum2 += adler
            len -= 16
            i += 16
        end

        # whatever is left is not unrolled
        @inbounds while len > 0
            adler += data[i]
            sum2 += adler
            len -= 1
            i += 1
        end

        adler %= BASE
        sum2 %= BASE
    end

    return adler | (sum2 << 16) % UInt32
end