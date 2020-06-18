"""
    onePointCross(parent1::GPGenotype, parent2::GPGenotype,
                  gpExperimentInfo::GPExperimentInfo, rng::Random.AbstractRNG)

documentation
"""
function onePointCross(parent1::GPGenotype, parent2::GPGenotype,
                       gpExperimentInfo::GPExperimentInfo, rng::Random.AbstractRNG)
    error("No onePointCross method defined for this type of genotype: ", typeof(parent1))
end # function



"""
    oneChildSubtreeCross(parent1::GPGenotype, parent2::GPGenotype,
                         gpExperimentInfo::GPExperimentInfo, rng::Random.AbstractRNG)

documentation
"""
function oneChildSubtreeCross(parent1::GPGenotype, parent2::GPGenotype,
                              gpExperimentInfo::GPExperimentInfo, rng::Random.AbstractRNG)
    error("No oneChildSubtreeCross method defined for this type of genotype: ", typeof(parent1))
end # function



"""
    subtreeCross(parent1::GPGenotype, parent2::GPGenotype,
                 gpExperimentInfo::GPExperimentInfo, rng::Random.AbstractRNG)

documentation
"""
function subtreeCross(parent1::GPGenotype, parent2::GPGenotype,
                      gpExperimentInfo::GPExperimentInfo, rng::Random.AbstractRNG)
    error("No subtreeCross method defined for this type of genotype: ", typeof(parent1))
end # function
