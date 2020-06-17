"""
    onePointMutation(genotype::CGPGenotype, gpExperimentInfo::CGPInfo,
                     rng::Random.AbstractRNG)

Selects a node from a tree and mutates it into another one.

`Self-provided Arguments` are provided by the library, so only `User Arguments` must be provided.

# Self-provided Arguments
- `genotype::CGPGenotype`: genotype of the individual that is going to be mutated.
- `gpExperimentInfo::CGPInfo`: information about the GP experiment.
- `rng::Random.AbstractRNG)`: random number generator for random number consistency
    along an experiment.

# User Arguments
None

# Returns
The instance of type `STGPGenotype` mutated.
"""
function onePointMutation(genotype::STGPGenotype, gpExperimentInfo::STGPInfo,
                          rng::Random.AbstractRNG)

    terminalSet = deepcopy(gpExperimentInfo._terminalSet)
    functionSet = gpExperimentInfo._functionSet

    representation = genotype._representation
    mutatedChild = deepcopy(representation)

    # Choose a mutation point
    lenRep = length(representation)
    indexes = collect(1:lenRep)
    mutIndex = rand(rng, indexes)

    # Replace the selected node with one of the same arity
    if (chosenNode = chooseAnotherNode(representation[mutIndex], terminalSet,
        functionSet, rng, getType(representation[mutIndex]))) != nothing
        mutatedChild[mutIndex] = chosenNode
    end

    return STGPGenotype(mutatedChild)
end # function



"""
    pointMutation(genotype::CGPGenotype, gpExperimentInfo::CGPInfo,
                  rng::Random.AbstractRNG, probability::Float64)

Mutates the nodes of a tree with a certain probability.

`Self-provided Arguments` are provided by the library, so only `User Arguments` must be provided.

# Self-provided Arguments
- `genotype::CGPGenotype`: genotype of the individual that is going to be mutated.
- `gpExperimentInfo::CGPInfo`: information about the GP experiment.
- `rng::Random.AbstractRNG)`: random number generator for random number consistency
    along an experiment.

# User Arguments
- `probability::Float64`: probability of mutation for each node.

# Returns
The instance of type `STGPGenotype` mutated.
"""
function pointMutation(genotype::STGPGenotype, gpExperimentInfo::STGPInfo,
                       rng::Random.AbstractRNG, probability::Float64)

    terminalSet = deepcopy(gpExperimentInfo._terminalSet)
    functionSet = gpExperimentInfo._functionSet

    representation = deepcopy(genotype._representation)
    lenRep = length(representation)
    mutatedChild = Array{Node}(undef, lenRep)

    for i=1:lenRep
        prob = rand(rng)

        if prob < probability
            if (chosenNode = chooseAnotherNode(representation[i], terminalSet,
                functionSet, rng, getType(representation[i]))) != nothing
                mutatedChild[i] = chosenNode
            else
                mutatedChild[i] = representation[i]
            end
        else
            mutatedChild[i] = representation[i]
        end
    end

    return STGPGenotype(mutatedChild)
end # function



"""
    subtreeMutation(genotype::STGPGenotype,
                    gpExperimentInfo::STGPInfo,
                    rng::Random.AbstractRNG,
                    method::Function = fullGenerator)

Performs a subtree mutation for the given genotype. The subtree mutation performs
a crossover operation between the given genotype and a random generated one.

!!! note
    `Self-provided Arguments` are provided by the library, so only `User Arguments` must be provided.

# Self-provided Arguments
- `genotype::STGPGenotype`: genotype of the individual that is
    going to be mutated.
- `gpExperimentInfo::STGPInfo`: information about the GP experiment.
- `rng::Random.AbstractRNG`: random number generator for random number consistency
    along an experiment.
- `method::Function = fullGenerator`: generation method for the random generated
    tree that is going to be crossed with the given one.

# User arguments
None.

# Returns
The mutated genotype.
"""
function subtreeMutation(genotype::STGPGenotype,
                         gpExperimentInfo::STGPInfo,
                         rng::Random.AbstractRNG,
                         method::Function = fullGenerator)

    randomGenotype = method(gpExperimentInfo, rng)
    mutatedGenotype = oneChildSubtreeCross(genotype, randomGenotype, gpExperimentInfo, rng)[1]

    return mutatedGenotype
end # function



"""
    getDefaultMutationOp(individualType::DataType)::Tuple{Function, Array}

Returns a default mutation method for each registered individual type. For
`BinaryGenotype`, it is [`standardMutation`](@ref) with a probability of 0.1;
for `IntegerGenotype`, it is [`uniformMutation`](@ref) of one gene within a range of 0:10;
for both `CGPGenotype` and `STGPGenotype` it is [`pointMutation`](@ref) with a
probability of 0.2; for `GEPGenotype` it is [`geneMutation`](@ref).
"""
function getDefaultMutationOp(individualType::Type{STGPGenotype})::Tuple{Function, Array}
    return subtreeMutation, []
end # function
