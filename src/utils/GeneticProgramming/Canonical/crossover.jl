"""
    selectCrossPoint(genotype::CGPGenotype, rng::Random.AbstractRNG;
                     fixedDepth::Int64 = -1, minDepth::Int64 = -1,
                     maxDepth::UInt16 = -1)

Selects a point in the genotype where the crossover is going to be performed
by taking some considerations into account, such as the maximum depth allowed.

# Arguments
- `genotype::CGPGenotype`: genotype from which the cross point is going to be
    selected.
- `rng::Random.AbstractRNG`: random number generator for random number consistency
    along an experiment.

# Keyword Arguments
- `fixedDepth::Int64 = -1`: specifies the exact depth at where the crosspoint
    must be. If this argument is set to -1, it will be ignored.
- `minDepth::Int64 = -1`: specifies the minimum depth at where the crosspoint
    can be. If this argument is set to -1, it will be ignored.
- `maxDepth::UInt16 = -1`: specifies the maximum depth at where the crosspoint
    can be. If this argument is set to -1, it will be ignored.
"""
function selectCrossPoint(genotype::CGPGenotype, rng::Random.AbstractRNG;
                          fixedDepth::Integer = -1, minDepth::Integer = -1,
                          maxDepth::Integer = -1)

    if fixedDepth != -1 && minDepth != -1
        minDepth = -1
    end

    representation = genotype._representation
    lenRep = length(representation)

    # Sets depths for every node
    depths = Array{Int64}(undef, lenRep)
    visitedFromRoot = zeros(Int64, 1, 2)
    nodeIndex = 1
    depths[nodeIndex] = 0
    parent = 0
    depth = 0

    while nodeIndex != 0

        if nodeIndex > size(visitedFromRoot)[1]
            visitedFromRoot = vcat(visitedFromRoot, zeros(Int64, 1, 2))
            depths[nodeIndex] = depth
            visitedFromRoot[end, 2] = parent
        end

        if visitedFromRoot[nodeIndex, 1] < getArity(representation[nodeIndex])
            parent = nodeIndex
            depth = depths[nodeIndex] + 1
            nodeIndex = size(visitedFromRoot)[1] + 1
        else
            nodeIndex = visitedFromRoot[nodeIndex, 2]
            if nodeIndex != 0
                visitedFromRoot[nodeIndex, 1] += 1
            end
        end
    end

    # Sets heights for every node
    local heights
    if fixedDepth == -1
        heights = Array{Int64}(undef, lenRep)
        heights[end] = 0
        stack = [lenRep]
        currIndex = lenRep - 1

        while currIndex > 0

            if typeof(representation[currIndex]) <: TerminalNode
                heights[currIndex] = 0
            elseif typeof(representation[currIndex]) <: FunctionNode
                childrenIndexes = Array{Int64}(undef, 0)
                for i=1:getArity(representation[currIndex])
                    push!(childrenIndexes, pop!(stack))
                end
                heights[currIndex] = maximum(heights[childrenIndexes]) + 1
            end

            push!(stack, currIndex)
            currIndex -= 1
        end
    end

    # Chooses cross point
    indexes = Random.shuffle(rng, collect(1:lenRep))
    pointIndex = 0

    if maxDepth != -1
        if fixedDepth != -1
            indexes = filter(x->depths[x]==fixedDepth, indexes)
        elseif minDepth != -1
            indexes = union(filter(x->depths[x]>=minDepth, indexes),
                            filter(x->heights[x]+minDepth<=maxDepth, indexes))
        end
    end

    for i in indexes
        random = rand(rng)
        prob = typeof(representation[i]) <: FunctionNode ? 0.9 : 0.1

        if random < prob
            pointIndex = i
            break
        end
    end

    if pointIndex == 0
        pointIndex = rand(rng, indexes)
    end

    # Subtree obtention
    subtree = Array{Node}(undef, 0)
    visitedFromRoot = zeros(Int64, 1, 2)
    push!(subtree, representation[pointIndex])
    nodeIndex = pointIndex
    parent = 0

    while nodeIndex != 0

        if (nodeIndex-pointIndex+1) > size(visitedFromRoot)[1]
            visitedFromRoot = vcat(visitedFromRoot, zeros(Int64, 1, 2))
            visitedFromRoot[end, 2] = parent
            push!(subtree, representation[nodeIndex])
        end

        if visitedFromRoot[nodeIndex-pointIndex+1, 1] < getArity(representation[nodeIndex])
            parent = nodeIndex
            nodeIndex = size(visitedFromRoot)[1] + pointIndex
        else
            nodeIndex = visitedFromRoot[nodeIndex-pointIndex+1, 2]
            if nodeIndex != 0
                visitedFromRoot[nodeIndex-pointIndex+1, 1] += 1
            end
        end
    end

    return subtree, pointIndex, depths[pointIndex]
end # function



"""
    onePointCross(parent1::CGPGenotype, parent2::CGPGenotype,
                  gpExperimentInfo::CGPInfo, rng::Random.AbstractRNG)

Performs a crossover between two parent trees in which the crosspoints are at the
same depth.

`Self-provided Arguments` are provided by the library, so only `User Arguments` must be provided.

# Self-provided Arguments
- `parent1::CGPGenotype`: first parent for the crossover operation.
- `parent2::CGPGenotype`: first parent for the crossover operation.
- `gpExperimentInfo::CGPInfo`: information about the GP experiment.
- `rng::Random.AbstractRNG`: random number generator for random number consistency along an experiment.

# User Arguments
None

# Returns
An array that contains the two resulting children.
"""
function onePointCross(parent1::CGPGenotype, parent2::CGPGenotype,
                       gpExperimentInfo::CGPInfo, rng::Random.AbstractRNG)

    maxDepth = gpExperimentInfo._maxTreeDepth

    subtree1, crossPoint1, pointDepth1 = selectCrossPoint(parent1, rng)
    subtree2, crossPoint2, pointDepth2 = selectCrossPoint(parent2, rng, fixedDepth=pointDepth1,
                                                maxDepth=maxDepth)
    child1Tree = mergeSubtrees(parent1, subtree2, crossPoint1, length(subtree1))
    child2Tree = mergeSubtrees(parent2, subtree1, crossPoint2, length(subtree2))

    return [CGPGenotype(child1Tree), CGPGenotype(child2Tree)]
end # function



"""
    oneChildSubtreeCross(parent1::CGPGenotype, parent2::CGPGenotype,
                         gpExperimentInfo::CGPInfo, rng::Random.AbstractRNG)

Performs the classical subtree cross between two parents but resulting in only
one child. Selects a random crosspoint in the first parent and then selects
another crosspoint in the second parent, knowing that it should not generate a
child that violates the maximum depth established.

`Self-provided Arguments` are provided by the library, so only `User Arguments` must be provided.

# Self-provided Arguments
- `parent1::CGPGenotype`: first parent for the crossover operation.
- `parent2::CGPGenotype`: first parent for the crossover operation.
- `gpExperimentInfo::CGPInfo`: information about the GP experiment.
- `rng::Random.AbstractRNG`: random number generator for random number consistency along an experiment.

# User Arguments
None

# Returns
An array that contains the resulting child.
"""
function oneChildSubtreeCross(parent1::CGPGenotype, parent2::CGPGenotype,
                              gpExperimentInfo::CGPInfo, rng::Random.AbstractRNG)

    maxDepth = gpExperimentInfo._maxTreeDepth

    subtree1, crossPoint1, pointDepth1 = selectCrossPoint(parent1, rng)
    subtree2, _, _ = selectCrossPoint(parent2, rng, minDepth=pointDepth1, maxDepth=convert(Int64,maxDepth))
    child1Tree = mergeSubtrees(parent1, subtree2, crossPoint1, length(subtree1))

    return [CGPGenotype(child1Tree)]
end # function



"""
    subtreeCross(parent1::CGPGenotype, parent2::CGPGenotype,
                 gpExperimentInfo::CGPInfo, rng::Random.AbstractRNG)

Performs the classical subtree cross between two parents. Selects a random
crosspoint in the first parent and then selects another crosspoint in the second
parent, knowing that it should not generate a child that violates the maximum
depth established. Then, repeats the same operation but taking the second parent
as it was the first one.

`Self-provided Arguments` are provided by the library, so only `User Arguments` must be provided.

# Self-provided Arguments
- `parent1::CGPGenotype`: first parent for the crossover operation.
- `parent2::CGPGenotype`: first parent for the crossover operation.
- `gpExperimentInfo::CGPInfo`: information about the GP experiment.
- `rng::Random.AbstractRNG`: random number generator for random number consistency along an experiment.

# User Arguments
None

# Returns
An array that contains the two resulting children.
"""
function subtreeCross(parent1::CGPGenotype, parent2::CGPGenotype,
                      gpExperimentInfo::CGPInfo, rng::Random.AbstractRNG)

    child1 = oneChildSubtreeCross(parent1, parent2, gpExperimentInfo, rng)[1]
    child2 = oneChildSubtreeCross(parent2, parent1, gpExperimentInfo, rng)[1]

    return [child1, child2]
end # function



"""
    getDefaultCrossover(individualType::DataType)::Tuple{Function, Array}

Returns a default crossover method for each registered individual type. For
all `GAGenotype`, it is [`uniformCross`](@ref),
for both `CGPGenotype` and `STGPGenotype` it is [`subtreeCross`](@ref) with a
probability of 0.2; for `GEPGenotype` it is [`kPointRecombinationCross`](@ref)
with one crosspoint.
"""
function getDefaultCrossoverOp(individualType::Type{CGPGenotype})::Tuple{Function, Array}
    return subtreeCross, []
end # function
