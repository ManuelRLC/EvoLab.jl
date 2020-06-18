"""
    geneMutation(genotype::GEPGenotype,
                 gpExperimentInfo::GEPInfo,
                 rng::Random.AbstractRNG)

documentation
"""
function geneMutation(genotype::GEPGenotype,
                      gpExperimentInfo::GEPInfo,
                      rng::Random.AbstractRNG)

    representation = deepcopy(genotype._representation)
    functionSet = gpExperimentInfo._functionSet
    terminalSet = deepcopy(gpExperimentInfo._terminalSet)
    headSize = gpExperimentInfo._head
    tailSize = gpExperimentInfo._tail
    lenRep = headSize + tailSize
    prob = lenRep < 5 ? 1/lenRep : 4/lenRep
    probTer = length(terminalSet) / (length(terminalSet) + length(functionSet))

    mutatedGenotype = Array{Node}(undef, lenRep)

    for i=1:headSize
        if (rand(rng) - (lenRep-i+1)*prob/(2*lenRep)) < prob
            if rand(rng) < probTer
                mutatedGenotype[i] = rand(rng, terminalSet)
            else
                mutatedGenotype[i] = rand(rng, functionSet)
            end
        else
            mutatedGenotype[i] = representation[i]
        end
    end

    for i=headSize+1:lenRep
        if (rand(rng) - (lenRep-i+1)*prob/(2*lenRep)) < prob
            mutatedGenotype[i] = rand(rng, terminalSet)
        else
            mutatedGenotype[i] = representation[i]
        end
    end

    return GEPGenotype(mutatedGenotype)
end # function
precompile(geneMutation, tuple(GEPGenotype, GEPInfo, Random._GLOBAL_RNG))
precompile(geneMutation, tuple(GEPGenotype, GEPInfo, Random.MersenneTwister))



"""
    getDefaultMutationOp(individualType::DataType)::Tuple{Function, Array}

Returns a default mutation method for each registered individual type. For
`BinaryGenotype`, it is [`standardMutation`](@ref) with a probability of 0.1;
for `IntegerGenotype`, it is [`uniformMutation`](@ref) of one gene within a range of 0:10;
for both `CGPGenotype` and `STGPGenotype` it is [`pointMutation`](@ref) with a
probability of 0.2; for `GEPGenotype` it is [`geneMutation`](@ref).
"""
function getDefaultMutationOp(individualType::Type{GEPGenotype})::Tuple{Function, Array}
    return geneMutation, []
end # function
