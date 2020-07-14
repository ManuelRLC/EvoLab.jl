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
struct STGPInfo <: GPExperimentInfo
    _functionSet::Array{FunctionNode}
    _terminalSet::Array{TerminalNode}
    _maxTreeDepth::UInt16
    _variables::Array{String}
    _varValues::Array{NamedTuple}
end # struct



"""
    setSTGPInfo(varValues...; nodesFile::String = "", maxTreeDepth::Integer = 3,
                genj::GenJulia = GenJ)

Sets the information about a Strongly Typed Genetic Programming problem.
This function constructs a structure of type `STGPInfo` and adds it to the GP
experiment information field of the experiment information of the main structure.

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
julia> setSTGPInfo(nodesFile="myNodesFile.json")
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

julia> setSTGPInfo(x, y, nodesFile="myNodesFile.json")
[...]
```

Setting a maximum tree depth of 4
```jldoctest
julia> setSTGPInfo(nodesFile="myNodesFile.json", maxTreeDepth=4)
[...]
```

See also: [`setCGPInfo`](@ref), [`setGEPInfo`](@ref), [`setGEInfo`](@ref),
[`setGPExperimentInfo`](@ref)
"""
function setSTGPInfo(varValues...; nodesFile::String = "", maxTreeDepth::Integer = 3,
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

    setGPExperimentInfo(STGPInfo(functionSet, terminalSet, maxTreeDepth, variables,
                                 valuesDict), genj=genj)
end # function
export setSTGPInfo



"
Main struct for Strongly Typed Genetic Programming individuals.

# Fields
- `_representation::Array{Node}`: representation of the individual as an array of
    Node.

See also: [`Node`](@ref)
"
struct STGPGenotype <: GPGenotype
    _representation::Array{Node}
end # struct



"""
    getGenotype(genotype::STGPGenotype)::STGPGenotype

Obtains a copy of the individuals' genotype.
"""
function copyGenotype(genotype::STGPGenotype)::STGPGenotype
    len = length(genotype._representation)
    copyGenotype = Array{Node}(undef, len)
    for i=eachindex(genotype._representation)
        copyGenotype[i] = deepcopy(genotype._representation[i])
    end
    return STGPGenotype(copyGenotype)
end # function



"""
    mergeSubtrees(original::STGPGenotype, subtree::Array{Node},
                  pointIndex::Integer, removedLen::Integer)

Merges two subtrees at the given merging point.
"""
function mergeSubtrees(original::STGPGenotype, subtree::Array{Node},
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
end
