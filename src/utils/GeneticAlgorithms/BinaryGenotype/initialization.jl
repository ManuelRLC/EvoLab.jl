"""
    randomBinaryGenerator(rng::Random.AbstractRNG, genotypeSize::Integer)::BinaryGenotype

Generates a binary individual with a uniform probability for each gen to take *true* or *false*.

`Selfprovided Arguments` are already provided by the library, so only `User Arguments` must be provided.

# Self-provided Arguments
- `rng::Random.AbstractRNG`: random number generator for random number consistency along an experiment.

# User Arguments
- `genotypeSize::Integer`: number of genes.
"""
function randomBinaryGenerator(rng::Random.AbstractRNG, genotypeSize::Integer)::BinaryGenotype

    # Memory allocation
    genotype = Array{Bool}(undef, genotypeSize)

    # For each gen
    for i = eachindex(genotype)
        if rand(rng, UInt8) > 127
            genotype[i] = true
        else
            genotype[i] = false
        end
    end

    return BinaryGenotype(genotype)
end # function
