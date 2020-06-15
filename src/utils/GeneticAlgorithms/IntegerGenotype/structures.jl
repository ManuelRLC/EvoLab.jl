"
Main struct for integer arrays genotypes used in GA.

# Fields
- `_representation::Array{Integer}`: representation of the individual as an array of
    Integer.
"
struct IntegerGenotype <: GAGenotype
    _representation::Array{Integer}
end # struct



"""
    getGenotype(genotype::IntegerGenotype)::IntegerGenotype

Obtains a copy of the individuals' genotype.
"""
function copyGenotype(genotype::IntegerGenotype)::IntegerGenotype
    copyGenotype = similar(Array{eltype(genotype._representation)}, axes(genotype._representation))
    for i=eachindex(genotype._representation)
        copyGenotype[i] = deepcopy(genotype._representation[i])
    end
    return IntegerGenotype(copyGenotype)
end # function
