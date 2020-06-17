"""
    selectCrossPoint(genotype::STGPGenotype, rng::Random.AbstractRNG;
                     fixedDepth::Int64 = -1, minDepth::Int64 = -1,
                     maxDepth::Int64 = -1,
                     allowedType::Union{DataType, Union} = Any,
                     forbidden::Array{Int64} = Array{Int64}(undef, 0))

Selects a point in the genotype where the crossover is going to be performed
by taking some considerations into account, such as the maximum depth
and the type allowed.

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
- `maxDepth::Int64 = -1`: specifies the maximum depth at where the crosspoint
    can be. If this argument is set to -1, it will be ignored.
- `allowedType::Union{DataType, Union} = Any`: specifies the allowed type that the
    crosspoint must have.
- `forbidden::Array{Int64} = Array{Int64}(undef, 0)`: array of the indexes
    of the nodes that are forbidden to be crosspoints because they have already
    been proved not to have a compatible crosspoint in the other parent.
"""
function selectCrossPoint(genotype::STGPGenotype, rng::Random.AbstractRNG;
                          fixedDepth::Int64 = -1, minDepth::Int64 = -1,
                          maxDepth::Int64 = -1,
                          allowedType::Union{DataType, Union} = Any,
                          forbidden::Array{Int64} = Array{Int64}(undef, 0))

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

    # Chooses cross point
    indexes = Array{Int64}(undef, 0)

    if allowedType == Any
        indexes = collect(1:lenRep)
    else
        for i=1:lenRep
            if getType(representation[i]) <: allowedType
                push!(indexes, i)
            end
        end
    end

    indexes = Random.shuffle(rng, filter(x->!in(x, forbidden), indexes))
    pointIndex = 0

    if maxDepth != -1
        if fixedDepth != -1
            indexes = union(filter(x->depths[x]==fixedDepth, indexes),
                            filter(x->heights[x]+fixedDepth<=maxDepth, indexes))
        elseif minDepth != -1
            indexes = union(filter(x->depths[x]>=minDepth, indexes),
                            filter(x->heights[x]+minDepth<=maxDepth, indexes))
        end
    end

    if !isempty(indexes)
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

        return subtree, pointIndex, depths[pointIndex], getType(representation[pointIndex])
    else
        return nothing
    end
end



"""
    onePointCross(parent1::STGPGenotype, parent2::STGPGenotype,
                  gpExperimentInfo::STGPInfo, rng::Random.AbstractRNG)

Performs a crossover between two parent trees in which the crosspoints are at the
same depth. First, a random crosspoint is chosen in the first parent, and in the
second parent, a crosspoint of the same type and depth is searched. If there is
no such crosspoint in the second parent, the process repeats and a different
crosspoint is chosen in the first parent. If crossover is not possible between the
two parents (due to type and depth constrictions) the parents are returned as children.

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
function onePointCross(parent1::STGPGenotype, parent2::STGPGenotype,
                       gpExperimentInfo::STGPInfo, rng::Random.AbstractRNG)

    maxDepth = gpExperimentInfo._maxTreeDepth
    forbidden = Array{Int64}(undef, 0)
    cantCross = false
    lenRep = length(parent1._representation)

    subtree1, crossPoint1, pointDepth1, allowedType = selectCrossPoint(parent1, rng)
    returned = selectCrossPoint(parent2, rng, fixedDepth=pointDepth1, maxDepth=convert(Int64,maxDepth),
                                allowedType=allowedType)

    while returned == nothing
        push!(forbidden, crossPoint1)
        if length(forbidden) == lenRep
            cantCross = true
            break
        end
        subtree1, crossPoint1, pointDepth1, allowedType = selectCrossPoint(parent1,
            rng, forbidden=forbidden)
        returned = selectCrossPoint(parent2, rng, fixedDepth=pointDepth1,
            maxDepth=maxDepth, allowedType=allowedType)
    end

    if !cantCross
        child1Tree = mergeSubtrees(parent1, returned[1], crossPoint1, length(subtree1))
        child2Tree = mergeSubtrees(parent2, subtree1, returned[2], length(returned[1]))
    else
        child1Tree = deepcopy(parent1._representation)
        child2Tree = deepcopy(parent2._representation)
    end

    return [STGPGenotype(child1Tree), STGPGenotype(child2Tree)]
end



"""
    oneChildSubtreeCross(parent1::STGPGenotype, parent2::STGPGenotype,
                         gpExperimentInfo::STGPInfo, rng::Random.AbstractRNG)

Performs the classical subtree cross between two parents but resulting in only
one child. Selects a random crosspoint in the first parent and then selects
another crosspoint in the second parent, knowing that it should not generate a
child that violates the maximum depth established and that it must be of the same
type as the crosspoint selected in the first parent. If crossover is not possible between the
two parents (due to type and depth constrictions) the parents are returned as children.

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
function oneChildSubtreeCross(parent1::STGPGenotype, parent2::STGPGenotype,
                              gpExperimentInfo::STGPInfo, rng::Random.AbstractRNG)

    maxDepth = gpExperimentInfo._maxTreeDepth
    forbidden = Array{Int64}(undef, 0)
    cantCross = false
    lenRep = length(parent1._representation)

    subtree1, crossPoint1, pointDepth1, allowedType = selectCrossPoint(parent1, rng)
    returned = selectCrossPoint(parent2, rng, minDepth=pointDepth1, maxDepth=convert(Int64,maxDepth),
               allowedType=allowedType)
    while returned == nothing
        push!(forbidden, crossPoint1)
        if length(forbidden) == lenRep
            cantCross = true
            break
        end
        subtree1, crossPoint1, pointDepth1, allowedType = selectCrossPoint(parent1,
            rng, forbidden=forbidden)
        returned = selectCrossPoint(parent2, rng, minDepth=pointDepth1,
            maxDepth=maxDepth, allowedType=allowedType)
    end
    if !cantCross
        childTree = mergeSubtrees(parent1, returned[1], crossPoint1, length(subtree1))
    else
        childTree = deepcopy(parent1._representation)
    end

    return [STGPGenotype(childTree)]
end



"""
    subtreeCross(parent1::STGPGenotype, parent2::STGPGenotype,
                 gpExperimentInfo::STGPInfo, rng::Random.AbstractRNG)

Performs the classical subtree cross between two parents. Selects a random
crosspoint in the first parent and then selects another crosspoint in the second
parent, knowing that it should not generate a child that violates the maximum
depth established and that it must be of the same type as the crosspoint selected
in the first parent. Then, repeats the same operation but taking the second parent
as it was the first one. If crossover is not possible between the
two parents (due to type and depth constrictions) the parents are returned as children.

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
function subtreeCross(parent1::STGPGenotype, parent2::STGPGenotype,
                      gpExperimentInfo::STGPInfo, rng::Random.AbstractRNG)

    child1 = oneChildSubtreeCross(parent1, parent2, gpExperimentInfo, rng)[1]
    child2 = oneChildSubtreeCross(parent2, parent1, gpExperimentInfo, rng)[1]

    return [child1, child2]
end



"""
    getDefaultCrossover(individualType::DataType)::Tuple{Function, Array}

Returns a default crossover method for each registered individual type. For
all `GAGenotype`, it is [`uniformCross`](@ref),
for both `CGPGenotype` and `STGPGenotype` it is [`subtreeCross`](@ref) with a
probability of 0.2; for `GEPGenotype` it is [`kPointRecombinationCross`](@ref)
with one crosspoint.
"""
function getDefaultCrossoverOp(individualType::Type{STGPGenotype})::Tuple{Function, Array}
    return subtreeCross, []
end # function
