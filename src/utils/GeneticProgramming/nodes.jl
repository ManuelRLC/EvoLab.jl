_noFunc_() = nothing



"Node is the abstract type that will contain every node of the expression tree."
abstract type Node end



"""
FunctionNode represents a non-terminal node of the expression tree.

# Arguments
- `_func::Function`: the actual function that will be executed for that function node.
- `_arity::Integer`: the number of parameters for the function, also, the number
    of children of the function node..
- `_returnType::Union{DataType, Union}`: type of the returning value of a function.
- `_argTypes::Array{Union{DataType, Union}}`: types of the arguments of the function.
"""
struct FunctionNode <: Node
    _func::Function
    _arity::Integer
    _returnType::Union{DataType, Union}
    _argTypes::Array{Union{DataType, Union}}


    function FunctionNode(func::Function, arity::Integer,
                          returnType::Union{DataType, Union},
                          argTypes::Array{Union{DataType, Union}})

        new(func, arity, returnType, argTypes)
    end # function

    function FunctionNode(func::Function, arity::Integer)
        new(func, arity, Any, Array{Union{DataType, Union}}(undef, 0))
    end # function
end # struct



"""
    getFunctionName(node::FunctionNode)

Gets the identifier of a given [`FunctionNode`](@ref).
"""
getFunctionName(node::FunctionNode) = string(node._func)
# function



"""
    getArity(node::FunctionNode)

Gets the arity of a given [`FunctionNode`](@ref).
"""
getFunctionArity(node::FunctionNode) = node._arity
# function



"""
    getReturnType(node::FunctionNode)

Gets the return type of a [`FunctionNode`](@ref).
"""
getReturnType(node::FunctionNode) = node._returnType
# function



"TerminalNode is an abstract type and represents a terminal node of the expression tree."
abstract type TerminalNode <: Node end



"
VariableNode represents an identifier with a value assigned by the user.
- `_name::String`: identifier of the variable.
- `_type::DataType`: type of the variable.

See also: [`TerminalNode`](@ref)
"
struct VariableNode <: TerminalNode
    _name::String
    _type::DataType
end # struct



"""
    getVariableName(node::VariableNode)

Gets the identifier of a [`VariableNode`](@ref).
"""
getVariableName(node::VariableNode) = node._name
# function



"""
    getVariableType(node::VariableNode)

Gets the type of a [`VariableNode`](@ref).
"""
getValueType(node::VariableNode) = node._type
# function



"
ConstantNode represents a single value.

# Fields
- `_value`: value of the constant.
- `_ephemeralFunction::Function`: if set, it determines that the constant is
    ephemeral, and this function, when evaluated, gives the constant its value.
- `_varArgs::Array{Any}`: arguments of the function of the ephemeral constant, if any.

See also: [`TerminalNode`](@ref)
"
mutable struct ConstantNode <: TerminalNode
    _value
    _ephemeralFunction::Function
    _varArgs::Array{Any}


    function ConstantNode(value)
        new(value, _noFunc_, [])
    end # function

    ConstantNode(ephemeralFunction::Function, varArgs::Array{Any}) = new(NaN, ephemeralFunction, varArgs)
    # function
end # struct



"""
    getConstantType(node::ConstantNode)

Determines wether a [`ConstantNode`](@ref) is ephemeral or not.
"""
function isEphemeralConstant(constantNode::ConstantNode)
    !(constantNode._ephemeralFunction == _noFunc_)
end # function



"""
    getConstantType(node::ConstantNode)

Gets the type of a [`ConstantNode`](@ref).
"""
getValueType(node::ConstantNode) = typeof(node._value)
# function



"""
    setEphemeralConstant(node::ConstantNode)

Sets the value of an ephemeral [`ConstantNode`](@ref).
"""
function setEphemeralConstant(node::ConstantNode)
    node._value = node._ephemeralFunction(node._varArgs...)
end # function



"""
    eval(node::ConstantNode)

Evaluates a [`ConstantNode`](@ref). If it is an ephemeral constant, sets the
value for that constant.
"""
function eval(node::ConstantNode)
    if isnan(node._value)
        setEphemeralConstant(node)
    end
    node._value
end
# function



"
NoArgsFunctionNode represents a function node that has 0 arity (no arguments)
and it's considered as a terminal node in the expression tree.

# Fields
- `_func::Function`: the actual function that will be executed for that terminal node.

See also: [`TerminalNode`](@ref)
"
struct NoArgsFunctionNode <: TerminalNode
    _func::Function
end # struct



"""
    getNoArgsFunctionName(node::NoArgsFunctionNode)

Gets the identifier of a [`NoArgsFunctionNode`](@ref).
"""
getNoArgsFunctionName(node::NoArgsFunctionNode) = string(node._func)
# function



"""
    getNoArgsFunctionType(node::NoArgsFunctionNode)

Obtains the return type of a [`NoArgsFunctionNode`](@ref).
"""
getReturnType(node::NoArgsFunctionNode) = typeof(node._func())
# function



"""
    eval(node::NoArgsFunctionNode)

Evaluates a [`NoArgsFunctionNode`](@ref).
"""
eval(node::NoArgsFunctionNode) = node._func()
# function



"""
    getName(node::Node)

Gets the identifier of the node.
"""
function getName(node::Node)
    if typeof(node) <: ConstantNode
        string(eval(node))
    elseif typeof(node) <: VariableNode
        getVariableName(node)
    elseif typeof(node) <: NoArgsFunctionNode
        getFunctionName(node)
    elseif typeof(node) <: FunctionNode
        getFunctionName(node)
    end
end # function



"""
    getType(node::Node)

Gets the type of the node.
"""
function getType(node::Node)
    if typeof(node) <: FunctionNode || typeof(node) <: NoArgsFunctionNode
        getReturnType(node)
    else
        getValueType(node)
    end
end # function



"""
    getArity(node::Node)

Gets the arity of a node.
"""
function getArity(node::Node)
    return typeof(node) <: FunctionNode ? getFunctionArity(node) : 0
end # function
