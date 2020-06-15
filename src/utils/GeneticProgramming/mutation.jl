"""
    subtreeMutation(genotype::Union{CGPGenotype, STGPGenotype},
                    gpExperimentInfo::Union{CGPInfo, STGPInfo},
                    rng::Random.AbstractRNG,
                    method::Function = fullGenerator)

Performs a subtree mutation for the given genotype. The subtree mutation performs
a crossover operation between the given genotype and a random generated one.

`Self-provided Arguments` are provided by the library, so only `User Arguments` must be provided.

# Self-provided Arguments
- `genotype::Union{CGPGenotype, STGPGenotype}`: genotype of the individual that is
    going to be mutated.
- `gpExperimentInfo::Union{CGPInfo, STGPInfo}`: information about the GP experiment.
- `rng::Random.AbstractRNG`: random number generator for random number consistency
    along an experiment.
- `method::Function = fullGenerator`: generation method for the random generated
    tree that is going to be crossed with the given one.

# User arguments
None.

# Returns
The mutated genotype.
"""
function subtreeMutation(genotype::Union{CGPGenotype, STGPGenotype},
                         gpExperimentInfo::Union{CGPInfo, STGPInfo},
                         rng::Random.AbstractRNG,
                         method::Function = fullGenerator)

    randomGenotype = method(gpExperimentInfo, rng)
    mutatedGenotype = oneChildSubtreeCross(genotype, randomGenotype, gpExperimentInfo, rng)[1]

    return mutatedGenotype
end # function
