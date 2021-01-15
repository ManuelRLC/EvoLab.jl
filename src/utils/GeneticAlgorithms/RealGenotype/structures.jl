"
Main struct for integer arrays genotypes used in GA.

# Fields
- `_representation::Array{Float64}`: representation of the individual as an array of
    Integer.
"
struct RealGenotype{T<:Real} <: GAGenotype
    _representation::Array{T}
end # struct



"""
    getGenotype(genotype::IntegerGenotype)::IntegerGenotype

Obtains a copy of the individuals' genotype.
"""
function copyGenotype(genotype::RealGenotype)::RealGenotype
    copyGenotype = similar(Array{eltype(genotype._representation)}, axes(genotype._representation))
    for i=eachindex(genotype._representation)
        copyGenotype[i] = deepcopy(genotype._representation[i])
    end
    return RealGenotype(copyGenotype)
end # function
