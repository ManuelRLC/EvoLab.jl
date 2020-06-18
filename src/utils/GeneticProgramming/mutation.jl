"""
    onePointMutation(genotype::GPGenotype, gpExperimentInfo::GPExperimentInfo,
                     rng::Random.AbstractRNG)

documentation
"""
function onePointMutation(genotype::GPGenotype, gpExperimentInfo::GPExperimentInfo,
                          rng::Random.AbstractRNG)
    error("No onePointMutation method for this type of genotype: ", typeof(genotype))
end # function



"""
    pointMutation(genotype::GPGenotype, gpExperimentInfo::GPExperimentInfo,
                  rng::Random.AbstractRNG)

documentation
"""
function pointMutation(genotype::GPGenotype, gpExperimentInfo::GPExperimentInfo,
                          rng::Random.AbstractRNG)
    error("No pointMutation method for this type of genotype: ", typeof(genotype))
end # function



"""
    subtreeMutation(genotype::GPGenotype,
                    gpExperimentInfo::GPExperimentInfo,
                    rng::Random.AbstractRNG,
                    method::Function = fullGenerator)

Performs a subtree mutation for the given genotype. The subtree mutation performs
a crossover operation between the given genotype and a random generated one.

!!! note
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
function subtreeMutation(genotype::GPGenotype,
                         gpExperimentInfo::GPExperimentInfo,
                         rng::Random.AbstractRNG,
                         method::Function = fullGenerator)

    error("No subtreeMutation method defined for this type of genotype: ", typeof(genotype))
end # function
