# Luhn: modulo 10 sum, doubling every other digit

function luhn(value::Integer)
    d = digits(value, base=10)
    len = length(d)
    i = 1
    ck = 0
    while len > 0
        x = iseven(i) ? d[i] : d[i] * 2
        if x > 10
            x = 1 + (x % 10)
        end
        ck += x
        len -= 1
        i += 1
    end
    return (10 - (ck % 10)) % 10
end