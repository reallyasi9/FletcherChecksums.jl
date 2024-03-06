"""
    additive_checksum(T, data, init::T = zero(T), modulo::T = typemax(T)) where {T<:Unsigned}

Compute a simple additive hash of the values in `data`.

Sums all the values in `data`, then computes modulo `modulo`, optionally starting from `init` instead of zero. Sums are allowed to overflow, which resets the sum to zero.

This function is extremely fast but suffers from many collisions. Flaws to keep in mind are:
1. zero values in `data` do not affect the checksum value at all;
2. the order of the values in `data` can be permuted without changing the checksum value; and
3. because of the modulo operation, the checksum of all zeros is equal to the checksum of all `modulo` values.

## Arguments
- `T`: An unsinged integer type.
- `data`: A single `Unsigned` value or an iterator of values.
- `init::Unsigned = zero(T)`: Optional starting value.
- `modulo::T = typemax(T)`: A number to use as the modulo for addition. Typical choices are `typemax(T)` (the default) or some prime number close to but less than `typemax(T)`.

Predefined convenience functions are `additive16`, `additive32`, and `additive64`.

See also: [sysv16](@ref) for a different way of folding the sum into a fixed number of bits.
"""
function additive_checksum(::Type{T}, data, init::Unsigned = zero(T), modulo::T = typemax(T)) where {T <: Unsigned}
    length(data) == 0 && return init % T
    length(data) == 1 && return additive_checksum(T, first(data), init, modulo)
    
    r = init % T + mapreduce(T, +, data)
    r %= modulo
    return r
end

@inline additive_checksum(::Type{T}, data::Unsigned, init::Unsigned = zero(T), modulo::T = typemax(T)) where {T <: Unsigned} = ((init % T) + (data % T)) % modulo

additive16(data, init::Integer = zero(UInt16), modulo::Integer = typemax(UInt16)) = additive_checksum(UInt16, data, UInt16(init), UInt16(modulo))
additive32(data, init::Integer = zero(UInt32), modulo::Integer = typemax(UInt32)) = additive_checksum(UInt32, data, UInt32(init), UInt32(modulo))
additive64(data, init::Integer = zero(UInt64), modulo::Integer = typemax(UInt64)) = additive_checksum(UInt64, data, UInt64(init), UInt64(modulo))