"
Auxiliary structure that keeps some generic information for GEP experiments.

# Fields
- `_functionSet::Array{FunctionNode}`: array that contains all the non-terminal
    nodes specified in the node information file.
- `_terminalSet::Array{TerminalNode}`: array that contains all the terminal nodes
    specified in the node information file.
- `_head::UInt16`: length of the head of the genotype.
- `_tail::UInt16`: length of the tail of the genotype. It is calculated as follows:
    t = h (n-1) + 1 , where n is the maximum arity of the non-terminal nodes of the
    problem.
- `_variables::Array{String}`: array that contains the names of the variables of
    the problem.
- `varValues::Array{NamedTuple}`: values for the variables of the problem.

See also: [`GPExperimentInfo`](@ref)
"
struct GEPInfo <: GPExperimentInfo
    _functionSet::Array{FunctionNode}
    _terminalSet::Array{TerminalNode}
    _head::UInt16
    _tail::UInt16
    _variables::Array{String}
    _varValues::Array{NamedTuple}
end # struct



"""
    setGEPInfo(varValues...; nodesFile::String = "", head::Integer = 7, genj::GenJulia = GenJ)

Sets the information about a Gene Expression Programming problem.
This function constructs a structure of type `GEPInfo` and adds it to the GP
experiment information field of the experiment information of the main structure.

# Arguments
- `varValues`: values for the variables of the problem. These values must be
    arrays of the same size containing the actual values for each variable. If
    the problem does not have any variable, this argument shall not be given by
    the user. (See Examples)

# Keyword Arguments
- `nodesFile::String = ""`: file in which the information about terminal and
    non-terminal nodes is. If this is not specified, the system provides with a
    file that is read by default and contains the simples arithmetic and boolean
    operations and terminals.
- `head::Integer = 7`: length of the head of the genotype, which will determine
    the total length of the genotype, along with the maximum arity of the non-terminals.
    If this argument is not specified, it will be 7 by default.
- `genj::GenJulia = GenJ`: the main structure. For `code user`: don't modify
    the default value unless multiple experiments are going to be run.

# Examples
Arguments set by default for a problem with no variables.
```jldoctest
julia> setGEPInfo(nodesFile="myNodesFile.json")
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

julia> setGEPInfo(x, y, nodesFile="myNodesFile.json")
[...]
```

Setting a head length of 5
```jldoctest
julia> setGEPInfo(nodesFile="myNodesFile.json", head=5)
[...]
```

See also: [`setCGPInfo`](@ref), [`setSTGPInfo`](@ref), [`setGEInfo`](@ref),
[`setGPExperimentInfo`](@ref)
"""
function setGEPInfo(varValues...; nodesFile::String = "", head::Integer = 7, genj::GenJulia = GenJ)

    if nodesFile == ""
        functionSet, terminalSet = createNodes("ECJ/utils/GeneticProgramming/GeneExpressionProgramming/exampleNodesGEP.json")
    elseif isfile(nodesFile)
        functionSet, terminalSet = createNodes(nodesFile)
    else
        error("Node information file $nodesFile does not exist in the specified directory")
    end

    if head <= 0
        error("Head length must be an integer number greater than 0")
    end

    # Maximum arity obtention
    maxArity = 0
    for func in functionSet
        if maxArity < func._arity
            maxArity = func._arity
        end
    end

    # Tail length calculation
    tail = head * (maxArity - 1) + 1

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

    setGPExperimentInfo(GEPInfo(functionSet, terminalSet, head, tail, variables,
                                valuesDict), genj=genj)
end # function
export setGEPInfo



"
Main struct for Gene Expression Programming individuals.

# Fields
- `_representation::Array{Node}`: representation of the individual as an array of
    Node.

See also: [`Node`](@ref)
"
struct GEPGenotype <: GPGenotype
    _representation::Array{Node}
end # struct



"""
    getGenotype(genotype::GEPGenotype)::GEPGenotype

Obtains a copy of the individuals' genotype.
"""
function copyGenotype(genotype::GEPGenotype)::GEPGenotype
    len = length(genotype._representation)
    copyGenotype = Array{Node}(undef, len)
    for i=eachindex(genotype._representation)
        copyGenotype[i] = deepcopy(genotype._representation[i])
    end
    return GEPGenotype(copyGenotype)
end # function
