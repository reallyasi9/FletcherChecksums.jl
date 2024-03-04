"""
    additive_checksum(T, data, init::T = zero(T), modulo::T = typemax(T)) where {T<:Unsigned}

    Compute a simple additive hash of the values in `data`.

Additive hash sums (with overflow) all the values in `data` modulo `modulo`, optionally starting from `init` instead of zero. This function is extremely fast but suffers from many collisions.

## Arguments
- `T`: An unsinged integer type.
- `data`: A sequence of values. Must implement `length(data)::Integer` and `getindex(data, ::Integer)`.
- `init::T = zero(T)`: Optional starting value.
- `modulo::T = typemax(T)`: A number to use as the modulo for addition. Typical choices are `typemax(T)` (the default) or some prime number close to but less than `typemax(T)`.
"""
function additive_checksum(::Type{T}, data, init::T = zero(T), modulo::T = typemax(T)) where {T <: Unsigned}
    for x in data
        init += (x % T)
    end
    init %= modulo
    return init
end

additive_checksum(::Type{T}, data::UInt8, init::T = zero(T), modulo::T = typemax(T)) where {T <: Unsigned} = (init + (data % T)) % modulo

additive16(data, init::Integer = zero(UInt16), modulo::Integer = typemax(UInt16)) = additive_checksum(UInt16, data, UInt16(init), UInt16(modulo))
additive32(data, init::Integer = zero(UInt32), modulo::Integer = typemax(UInt32)) = additive_checksum(UInt32, data, UInt32(init), UInt32(modulo))
additive64(data, init::Integer = zero(UInt64), modulo::Integer = typemax(UInt64)) = additive_checksum(UInt64, data, UInt64(init), UInt64(modulo))