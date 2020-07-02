"""
    proteinMutation(genotype::GEGenotype, gpExperimentInfo::GEInfo,
                        rng::Random.AbstractRNG, integerMutation::Function, varargs...)

Perform codons based mutation a **Grammatical Evolution** Individual, by means of
an integer mutation.

# Self-provided Arguments
- `genotype::GEGenotype`: individual genotype.
- `gpExperimentInfo::GEInfo`: information about grammatical evolution.
- `rng::Random.AbstractRNG`: random number generator for random number consistency along an experiment.

# User Arguments
- `integerMutation::Function`: integer mutation function.
- `varargs`: arguments for integerMutation.

!!! note
    `Selfprovided Arguments` are already provided by the library, so only `User Arguments` must be provided.
"""
function proteinMutation(genotype::GEGenotype, gpExperimentInfo::GEInfo,
                        rng::Random.AbstractRNG, integerMutation::Function, varargs...)


    protein, introns = pruneProtein(genotype)

    child = integerMutation(protein, rng, varargs...)

    child = generateTree(gpExperimentInfo, rng::Random.AbstractRNG, vcat(child._representation, introns))

    return child
end



"""
    proteinMutationGrow(genotype::GEGenotype, gpExperimentInfo::GEInfo,
                            rng::Random.AbstractRNG, integerMutation::Function, varargs...)

As proteinMutation, but instead, a growGenerator is used to ensure that all individuals are valids.
It is advisable to used along proteinCrossGrow.

# Self-provided Arguments
- `genotype::GEGenotype`: individual genotype.
- `gpExperimentInfo::GEInfo`: information about grammatical evolution.
- `rng::Random.AbstractRNG`: random number generator for random number consistency along an experiment.

# User Arguments
- `integerCross::Function`: integer crossover function.
- `varargs`: arguments for integerCross.

!!! note
    `Selfprovided Arguments` are already provided by the library, so only `User Arguments` must be provided.
"""
function proteinMutationGrow(genotype::GEGenotype, gpExperimentInfo::GEInfo,
                            rng::Random.AbstractRNG, integerMutation::Function, varargs...)

    protein, introns = pruneProtein(genotype)

    child = integerMutation(protein, rng, varargs...)

    child = growGenerator(gpExperimentInfo, rng::Random.AbstractRNG, vcat(child._representation, introns))

    return child
end



"""
    getDefaultMutationOp(individualType::DataType)::Tuple{Function, Array}

Returns a default mutation method for each registered individual type. For
`BinaryGenotype`, it is [`standardMutation`](@ref) with a probability of 0.1;
for `IntegerGenotype`, it is [`uniformMutation`](@ref) of one gene within a range of 0:10;
for both `CGPGenotype` and `STGPGenotype` it is [`pointMutation`](@ref) with a
probability of 0.2; for `GEPGenotype` it is [`geneMutation`](@ref).
"""
function getDefaultMutationOp(individualType::Type{GEGenotype})::Tuple{Function, Array}
    return proteinMutation, [uniformMutation, 0, 255]
end # function
