"
Main struct for binary arrays genotypes used in GA.

# Fields
- `_representation::Array{Bool}`: representation of the individual as an array of
    Bool.
"
struct BinaryGenotype <: GAGenotype
    _representation::Array{Bool}
end # struct



"""
    getGenotype(genotype::BinaryGenotype)::BinaryGenotype

Obtains a copy of the individuals' genotype.
"""
function copyGenotype(genotype::BinaryGenotype)::BinaryGenotype
    len = length(genotype._representation)
    copyGenotype = Array{Bool}(undef, len)
    for i=eachindex(genotype._representation)
        copyGenotype[i] = deepcopy(genotype._representation[i])
    end
    return BinaryGenotype(copyGenotype)
end # function
