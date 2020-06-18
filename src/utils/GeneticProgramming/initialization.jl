"""
    growGenerator(gpExperimentInfo::GPInfo, rng::Random.AbstractRNG)

documentation
"""
function growGenerator(gpExperimentInfo::GPExperimentInfo, rng::Random.AbstractRNG)
    error("No grow generation method defined for this GP experiment information: ", typeof(gpExperimentInfo))
end # function



"""
    fullGenerator(gpExperimentInfo::GPInfo, rng::Random.AbstractRNG)

documentation
"""
function fullGenerator(gpExperimentInfo::GPExperimentInfo, rng::Random.AbstractRNG)
    error("No full generation method defined for this GP experiment information: ", typeof(gpExperimentInfo))
end # function



"""
    fullGenerator(gpExperimentInfo::GPInfo, rng::Random.AbstractRNG)

documentation
"""
function rampedHalfHalfGenerator(gpExperimentInfo::GPExperimentInfo, popSize::UInt32,
                                 rng::Random.AbstractRNG, RHHFactor::Float64 = 0.5)
    error("No ramped half half generation method defined for this GP experiment information: ", typeof(gpExperimentInfo))
end # function
