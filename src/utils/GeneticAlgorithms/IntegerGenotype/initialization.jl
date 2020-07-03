"""
    randomIntegerGenerator(rng::Random.AbstractRNG, genotypeSize::Integer,
                           min::Integer, max::Integer)::IntegerGenotype

Generates an integer individual with genes generated randomly within **min** and **max**, both included.

`Selfprovided Arguments` are already provided by the library, so, only `User Arguments` must be provided.

# Selfprovided Arguments
- `rng::Random.AbstractRNG`: random number generator for random number consistency along an experiment.

# User Arguments
- `genotypeSize::Integer`: number of genes.
- `min::Integer`: lower limit for random generation.
- `max::Integer`: upper limit for random generation.
"""
function randomIntegerGenerator(rng::Random.AbstractRNG, genotypeSize::Integer,
                                min::Integer, max::Integer)::IntegerGenotype

    # Checks if user has introduced correctly the bounds
    if min > max
        min, max = max, min
    end
    # Memory reserve
    genotype = Array{Int64}(undef, genotypeSize)
    # Range for remainder
    range = max - min + 1

    # For each gen
    for i = eachindex(genotype)
        # Generates a number within range
        aux2 = abs(rand(rng, Int32))
        aux = (aux2%range)+min
        genotype[i] = aux
    end

    return IntegerGenotype{Int64}(genotype)
end # function
