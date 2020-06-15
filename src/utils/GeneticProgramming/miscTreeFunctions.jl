"""
    mergeSubtrees(original::Union{CGPGenotype, STGPGenotype}, subtree::Array{Node},
                  pointIndex::Integer, removedLen::Integer)

Merges two subtrees at the given merging point.
"""

"""function mergeSubtrees(original::Union{CGPGenotype, STGPGenotype}, subtree::Array{Node},
                       pointIndex::Integer, removedLen::Integer)

    originalTree = original._representation
    originalLen = length(originalTree)
    subtreeLen = length(subtree)
    newLen = originalLen - removedLen + subtreeLen
    childTree = Array{Node}(undef, newLen)

    for i=1:newLen
        if i < pointIndex
            childTree[i] = originalTree[i]
        elseif pointIndex <= i < (subtreeLen+pointIndex)
            childTree[i] = subtree[i-pointIndex+1]
        else
            childTree[i] = originalTree[i+(removedLen-subtreeLen)]
        end
    end

    return childTree
end"""



"""
    chooseAnotherNode(node::Node, terminalSet::Array{TerminalNode},
                      functionSet::Array{FunctionNode}, rng::Random.AbstractRNG,
                      allowedType::Union{DataType, Union} = Any)

Chooses, if possible, another node of the same arity and type of the given one.
Returns `nothing` if such node does not exist.
"""
function chooseAnotherNode(node::Node, terminalSet::Array{TerminalNode},
                           functionSet::Array{FunctionNode}, rng::Random.AbstractRNG,
                           allowedType::Union{DataType, Union} = Any)
    local newSet
    if allowedType == Any
        if typeof(node) <: TerminalNode
           newSet = filter(x->x!=node, terminalSet)
        elseif typeof(node) <: FunctionNode
           arity = getArity(node)
           newSet = filter(x->getArity(x)==arity && x!=node, functionSet)
        end
    else
        if typeof(node) <: TerminalNode
           newSet = filter(x->getType(x)<:allowedType && x!=node, terminalSet)
        elseif typeof(node) <: FunctionNode
           arity = getArity(node)
           newSet = filter(x->getType(x)<:allowedType && getArity(x)==arity && x!=node, functionSet)
        end
    end

    return !isempty(newSet) ? rand(rng, newSet) : nothing
end # function
