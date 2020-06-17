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
