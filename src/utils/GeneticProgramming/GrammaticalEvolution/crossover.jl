"""
    proteinCross(genotype1::GEGenotype, genotype2::GEGenotype,
                            gpExperimentInfo::GEInfo, rng::Random.AbstractRNG,
                            integerCross::Function = singlePointCross, varargs...)::Array{GEGenotype}

Perform codons based cross for two **Grammatical Evolution** Individuals, by means of
an integer cross.

# Self-provided Arguments
- `genotype1::GEGenotype`: first parent genotype.
- `genotype2::GEGenotype`: second parent genotype.
- `gpExperimentInfo::GEInfo`: information about grammatical evolution.
- `rng::Random.AbstractRNG`: random number generator for random number consistency along an experiment.

# User Arguments
- `integerCross::Function`: integer crossover function.
- `varargs`: arguments for integerCross.

!!! note
    `Selfprovided Arguments` are already provided by the library, so only `User Arguments` must be provided.
"""
function proteinCross(genotype1::GEGenotype, genotype2::GEGenotype,
                            gpExperimentInfo::GEInfo, rng::Random.AbstractRNG,
                            integerCross::Function = singlePointCross, varargs...)::Array{GEGenotype}


    protein1, introns1, protein2, introns2 = pruneProtein(genotype1, genotype2)

    children = integerCross(protein1, protein2, rng, varargs...)

    child1 = generateTree(gpExperimentInfo, rng::Random.AbstractRNG, vcat(children[1]._representation, introns1))
    child2 = generateTree(gpExperimentInfo, rng::Random.AbstractRNG, vcat(children[2]._representation, introns2))
    return [child1, child2]
end



"""
    proteinCrossGrow(genotype1::GEGenotype, genotype2::GEGenotype,
                            gpExperimentInfo::GEInfo, rng::Random.AbstractRNG,
                            integerCross::Function = singlePointCross, varargs...)::Array{GEGenotype}

As proteinCross, but instead, a growGenerator is used to ensure that all individuals are valids.
It is advisable to used along proteinMutationGrow.

# Self-provided Arguments
- `genotype1::GEGenotype`: first parent genotype.
- `genotype2::GEGenotype`: second parent genotype.
- `gpExperimentInfo::GEInfo`: information about grammatical evolution.
- `rng::Random.AbstractRNG`: random number generator for random number consistency along an experiment.

# User Arguments
- `integerCross::Function`: integer crossover function.
- `varargs`: arguments for integerCross.

!!! note
    `Selfprovided Arguments` are already provided by the library, so only `User Arguments` must be provided.
"""
function proteinCrossGrow(genotype1::GEGenotype, genotype2::GEGenotype,
                            gpExperimentInfo::GEInfo, rng::Random.AbstractRNG,
                            integerCross::Function = singlePointCross, varargs...)


    protein1, introns1, protein2, introns2 = pruneProtein(genotype1, genotype2)

    children = integerCross(protein1, protein2, rng, varargs...)

    child1 = growGenerator(gpExperimentInfo, rng, vcat(children[1]._representation, introns1))
    child2 = growGenerator(gpExperimentInfo, rng, vcat(children[2]._representation, introns2))

    return [child1, child2]
end




# TODO Fails
"""
function onePointCrossDepth(parent1::GEGenotype, parent2::GEGenotype,
                       gpExperimentInfo::GEInfo, rng::Random.AbstractRNG)

    maxDepth = gpExperimentInfo._maxDepth
    child1 = copyGenotype(parent1)
    child2 = copyGenotype(parent2)

    preOrder1 = getPreOrder(child1._tree)
    preOrder2 = getPreOrder(child2._tree)

    posibleValues = collect(1:length(preOrder1))
    posibleValues = filter(x->!isLeaf(preOrder1[x]), posibleValues)

    heights = zeros(UInt16, length(preOrder2))

    heights1 = getHeights(child1._tree)
    heights2 = getHeights(child2._tree)

    found = false

    while !isempty(posibleValues) && !found
        selected = rand(rng, posibleValues)
        posibleValues[selected], posibleValues[end] = posibleValues[end], posibleValues[selected]

        nodeIndex = pop!(posibleValues)
        symbol1 = getSymbol(preOrder1[nodeIndex])
        depth1 = getDepth(preOrder1[nodeIndex])
        height1 = heights1[nodeIndex]

        posiblesNodes = Array{GERep}(undef,0)

        for i=1:length(preOrder2)
            node = preOrder2[i]
            if getSymbol(node) == symbol1
                if height1 == heights2[i]
                    found = true
                    changeNodes!(preOrder1[nodeIndex], node)
                elseif height1 > heights2[i]
                    if height1 + getDepth(node) <= maxDepth
                        found = true
                        changeNodes!(preOrder1[nodeIndex], node)
                    end
                else
                    if height2 + depth1 <= maxDepth
                        found = true
                        changeNodes!(preOrder1[nodeIndex], node)
                    end
                end
            end
        end
    end

    return [child1, child2]
end
"""



"""
    getDefaultCrossover(individualType::DataType)::Tuple{Function, Array}

Returns a default crossover method for each registered individual type. For
all `GAGenotype`, it is [`uniformCross`](@ref),
for both `CGPGenotype` and `STGPGenotype` it is [`subtreeCross`](@ref) with a
probability of 0.2; for `GEPGenotype` it is [`kPointRecombinationCross`](@ref)
with one crosspoint.
"""
function getDefaultCrossoverOp(individualType::Type{GEGenotype})::Tuple{Function, Array}
    return proteinCross, []
end # function
