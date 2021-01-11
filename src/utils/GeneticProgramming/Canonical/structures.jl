"
Auxiliary structure that keeps some generic information for STGP experiments.

# Fields
- `_functionSet::Array{FunctionNode}`: array that contains all the non-terminal
    nodes specified in the node information file.
- `_terminalSet::Array{TerminalNode}`: array that contains all the terminal nodes
    specified in the node information file.
- `_maxTreeDepth::UInt16`: maximum tree depth permitted.
- `_variables::Array{String}`: array that contains the names of the variables of
    the problem.
- `varValues::Array{NamedTuple}`: values for the variables of the problem.

See also: [`GPExperimentInfo`](@ref)
"
struct CGPInfo <: GPExperimentInfo
    _functionSet::Array{FunctionNode}
    _terminalSet::Array{TerminalNode}
    _maxTreeDepth::UInt16
    _variables::Array{String}
    _varValues::Array{NamedTuple}
end # struct



"""
    setCGPInfo(varValues...; nodesFile::String = "", maxTreeDepth::Integer = 3,
               genj::GenJulia = GenJ)

Sets the information about a Canonical Genetic Programming problem.
This function constructs a structure of type `CGPInfo` and adds it to the GP
experiment info field of the experiment info of the main structure.

# Arguments
- `varValues`: values for the variables of the problem. These values must be
    arrays of the same size containing the actual values for each variable. If
    the problem does not have any variable, this argument shall not be given by
    the user. (See Examples)

# Keyword Arguments
- `nodesFile::String = ""`: file in which the information about terminal and
    non-terminal nodes is. If this is not specified, the system provides with a
    file that is read by default and contains the simples arithmetic operations and terminals.
- `maxTreeDepth::Integer = 3`: maximum tree depth permitted. If this argument is
    not specified, it will be 3 by default.
- `genj::GenJulia = GenJ`: the main structure. For `code user`: don't modify
    the default value unless multiple experiments are going to be run.

# Examples
Arguments set by default for a problem with no variables.
```jldoctest
julia> setCGPInfo(nodesFile="myNodesFile.json")
[...]
```

Arguments set by default for a problem with 2 variables.
```jldoctest
julia> xValues = collect(-5:0.5:5)
21-element Array{Float64,1}:
[...]

julia> yValues = collect(0:0.5:10)
21-element Array{Float64,1}:
[...]

julia> setCGPInfo(x, y, nodesFile="myNodesFile.json")
[...]
```

Setting a maximum tree depth of 4.
```jldoctest
julia> setCGPInfo(nodesFile="myNodesFile.txt", maxTreeDepth=4)
[...]
```

See also: [`setSTGPInfo`](@ref), [`setGEPInfo`](@ref), [`setGEInfo`](@ref),
[`setGPExperimentInfo`](@ref)
"""
function setCGPInfo(varValues...; nodesFile::String = "", maxTreeDepth::Integer = 3,
                    genj::GenJulia = GenJ)

    if nodesFile == ""
        error("A node information file must be provided")
    elseif isfile(nodesFile)
        if isdefined(genj._experimentInfo, :_parentModule)
            functionSet, terminalSet = createNodes(nodesFile, genj._experimentInfo._parentModule)
        else
            functionSet, terminalSet = createNodes(nodesFile, Main)
        end
    else
        error("Node information file $nodesFile does not exist in the specified directory")
    end

    functionSet = unique(functionSet)

    if maxTreeDepth <= 0
        error("Maximum tree depth must be an integer number greater than 0")
    end

    # Variables' names obtention
    variables = getName.(filter(x -> typeof(x) <: VariableNode, terminalSet))
    nVars = size(variables)[1]

    # Obtention of variable values
    if nVars > 0

        nValues = size(varValues[1])[1]
        for i=eachindex(varValues)
            if size(varValues[i])[1] != nValues
                error("All the variables must have the same number of values")
            end
        end

        varValues = [i for i in varValues]
        vars = [Meta.parse(x) for x in variables]
        vars = (vars...,)
        values = Array{Number}(undef, nVars)
        valuesDict = Array{NamedTuple}(undef, nValues)
        for i=1:nValues
            for j=1:nVars
                values[j] = varValues[j][i]
            end
            valuesDict[i] = NamedTuple{vars}(values)
        end
    else
        valuesDict = Array{NamedTuple}(undef, 0)
    end

    setGPExperimentInfo(CGPInfo(functionSet, terminalSet, maxTreeDepth, variables,
                                valuesDict), genj=genj)
end # function
export setCGPInfo



"
Main struct for Canonical Genetic Programming individuals.

# Fields
- `_representation::Array{Node}`: representation of the individual as an array of
    Node.

See also: [`Node`](@ref)
"
struct CGPGenotype <: GPGenotype
    _representation::Array{Node}
end # struct



"""
    getGenotype(genotype::CGPGenotype)::CGPGenotype

Obtains a copy of the individuals' genotype.
"""
function copyGenotype(genotype::CGPGenotype)::CGPGenotype
    len = length(genotype._representation)
    copyGenotype = Array{Node}(undef, len)
    for i=eachindex(genotype._representation)
        copyGenotype[i] = deepcopy(genotype._representation[i])
    end
    return CGPGenotype(copyGenotype)
end # function



"""
    mergeSubtrees(original::CGPGenotype, subtree::Array{Node},
                  pointIndex::Int64, removedLen::Int64)

Merges two subtrees at the given merging point.
"""
function mergeSubtrees(original::CGPGenotype, subtree::Array{Node},
                       pointIndex::Int64, removedLen::Int64)

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
end
