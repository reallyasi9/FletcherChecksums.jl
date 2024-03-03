
"""
    additive_hash(T, data, prime::T, init::T = T(0)) where {T<:Unsigned}

    Compute a simple additive hash of the values in `data`.

Additive hash sums (with overflow) all the values in `data` modulo `prime`, optionally starting from `init`
instead of zero. This function is extremely fast but suffers from many collisions.

## Arguments
- `T`: An unsinged integer type.
- `data`: A sequence of values. Must implement `length(data)::Integer` and `getindex(data, ::Integer)`.
- `mask::T = typemax(T)`: A prime number to use as the modulo for addition.
- `init::T = T(0)`: Optional starting value.
"""
function additive_hash(::Type{T}, data, mask::T = typemax(T), init::T = zero(T)) where {T <: Unsigned}
    len = length(data)
    i = 1
    while len > 0
        init += (data[i] % T)
        len -= 1
        i += 1
    end
    init %= mask
    return init
end