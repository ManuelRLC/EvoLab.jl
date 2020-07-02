function onePointMutation(genotype::GPGenotype, gpExperimentInfo::GPExperimentInfo,
                          rng::Random.AbstractRNG)
    error("No onePointMutation method for this type of genotype: ", typeof(genotype))
end # function



function pointMutation(genotype::GPGenotype, gpExperimentInfo::GPExperimentInfo,
                          rng::Random.AbstractRNG)
    error("No pointMutation method for this type of genotype: ", typeof(genotype))
end # function



function subtreeMutation(genotype::GPGenotype,
                         gpExperimentInfo::GPExperimentInfo,
                         rng::Random.AbstractRNG,
                         method::Function = fullGenerator)

    error("No subtreeMutation method defined for this type of genotype: ", typeof(genotype))
end # function
