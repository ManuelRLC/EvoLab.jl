"""
    parseFunctionNode(nodeDict::Dict)

Parses a [`FunctionNode`](@ref) from a node set configuration file.
"""
function parseFunctionNode(nodeDict::Dict)

    func = get(nodeDict, "function", false)
    if func == false
        error("function field is not set in FunctionNode")
    else
        aux = 0
        try
            aux = eval(Meta.parse(func))
        catch e
            error("The following function: '$func' in FunctionNode is not defined")
        end
        if typeof(aux) <: Function
            func = aux
        else
            error("The following function: '$func' in FunctionNode is not a function")
        end
    end

    arity = get(nodeDict, "arity", false)
    if arity == false
        error("arity field is not set in FunctionNode: '$func'")
    else
        if !(typeof(arity) <: Integer)
            error("arity field ($arity) in FunctionNode '$func' must be an integer number")
        elseif arity <= 0
            error("Arity must be an integer greater than 0 in FunctionNode: '$func'")
        end
    end

    returnType = get(nodeDict, "returnType", "")
    if !(typeof(returnType) <: String)
        error("returnType field must be a string in FunctionNode: '$func'")
    end
    if returnType != ""
        aux = 0
        try
            aux = eval(Meta.parse(returnType))
        catch e
            error("The following type: '$returnType' in TerminalNode: '$func' is not defined")
        end
        if typeof(aux) <: DataType || typeof(aux) <: Union
            returnType = aux
        else
            error("The following type: '$returnType' in TerminalNode: '$func' is not a type")
        end
    else
        error("Function nodes must have a return type in FunctionNode: '$func'")
    end

    argTypes = get(nodeDict, "argumentTypes", false)
    if argTypes == false
        error("Function nodes must have a list of argument types in FunctionNode: '$func'")
    end

    if arity == 1 && !(typeof(argTypes) <: Array)
        argTypes = [argTypes]
    elseif arity > 1 && !(typeof(argTypes) <: Array)
        error("argumentTypes field must be an array of string when arity is greater than 1 in FunctionNode: '$func'")
    elseif arity > 1 && !(typeof(argTypes) <: Array)
        error("argumentTypes field must be an array of string when arity is greater than 1 in FunctionNode: '$func'")
    end

    if length(argTypes) != arity
        error("Number of elements in argumentTypes field must match arity field in FunctionNode: '$func'")
    end

    for i=1:length(argTypes)
        if !(typeof(argTypes[i]) <: String)
            error("The elements of argumentTypes field must be strings in FunctionNode: '$func'")
        end
        try
            aux = eval(Meta.parse(argTypes[i]))
        catch e
            error("The following type: '$(argTypes[i])' in TerminalNode: '$func' is not defined")
        end
        if typeof(aux) <: DataType || typeof(aux) <: Union
            argTypes[i] = aux
        else
            error("The following type: '$(argTypes[i])' in TerminalNode: '$func' is not a type")
        end
    end
    argTypes = Array{Union{DataType, Union}}(argTypes)

    return FunctionNode(func, arity, returnType, argTypes)
end # function


"""
    parseTerminalNode(nodeDict::Dict)

Parses a [`TerminalNode`](@ref) from a node set configuration file.
"""
function parseTerminalNode(nodeDict::Dict)
    terminalNode = 0

    kind = get(nodeDict, "kind", false)
    if kind == false
        error("kind field not specified in TerminalNode")
    elseif !(typeof(kind) <: String)
        error("kind field in TerminalNode must be one of these strings: \"variable\", \"constant\", \"ephemeralConstant\" or \"terminalFunction\"")
    end

    if kind == "variable"

        name = get(nodeDict, "name", false)
        if name == false
            error("name field is not set in TerminalNode of kind variable")
        else
            if !(typeof(name) <: String)
                error("name field ($name) in TerminalNode of kind variable '$name' must be a string")
            end
        end

        type = get(nodeDict, "type", false)
        if type == false
            error("TerminalNode of kind variable '$name' has no type specified")
        end
        aux = 0
        try
            aux = eval(Meta.parse(type))
        catch e
            error("The following type: '$type' in TerminalNode: '$name' is not defined")
        end
        if typeof(aux) <: DataType
            type = aux
        else
            error("The following type: '$type' in TerminalNode: '$name' is not a type")
        end

        terminalNode = VariableNode(name, type)

    elseif kind == "constant"

        value = get(nodeDict, "value", nothing)
        if value == nothing
            error("TerminalNode of kind constant has no value")
        end

        try
            aux = Meta.parse(value)
            value = eval(aux)
        catch e
            # Empty
        end

        terminalNode = ConstantNode(value)

    elseif kind == "ephemeralConstant"

        func = get(nodeDict, "function", false)
        if func == false
            error("TerminalNode of kind ephemeralConstant has no function")
        else
            aux = 0
            try
                aux = eval(Meta.parse(func))
            catch e
                error("The following function: '$func' in TerminalNode of kind ephemeralConstant is not defined")
            end
            if typeof(aux) <: Function
                func = aux
            else
                error("The following function: '$func' TerminalNode of kind ephemeralConstant is not a function")
            end
        end

        varArgs = get(nodeDict, "arguments", [])
        if !(typeof(varArgs) <: Array)
            aux = Array{Any}(undef, 1)
            aux[1] = varArgs
            varArgs = aux
        end

        for i=1:length(varArgs)
            try
                arg = Meta.parse(varArgs[i])
                varArgs[i] = eval(arg)
            catch e
                # Empty
            end
        end

        terminalNode = ConstantNode(func, varArgs)

    elseif kind == "terminalFunction"

        func = get(nodeDict, "function", false)
        if func == false
            error("TerminalNode of kind terminalFunction '$func' has no function")
        else
            aux = 0
            try
                aux = eval(Meta.parse(func))
            catch e
                error("The following function: '$func' in TerminalNode of kind terminalFunction is not defined")
            end
            if typeof(aux) <: Function
                func = aux
            else
                error("The following function: '$func' TerminalNode of kind terminalFunction is not a function")
            end
        end

        terminalNode = NoArgsFunctionNode(func)
    else
        error("kind field of TerminalNode not supported: '$kind'")
    end

    return terminalNode
end # function


"""
    createNodes(jsonFile::String, verbose::Bool=true)

Parses a node set configuration file that contains the information about the
nodes of a Genetic Programming problem.
"""
function createNodes(jsonFile::String)

    if !isfile(jsonFile)
        error("File $jsonFile does not exist in working directory")
    end

    file=open(jsonFile)
    dictionary = JSON.parse(file)
    close(file)

    if get(dictionary, "FunctionNodes", false) == false
        error("Nodes configuration file '$jsonFile' must have function nodes")
    end
    if get(dictionary, "TerminalNodes", false) == false
        error("Nodes configuration file '$jsonFile' must have terminal nodes")
    end

    nFunctions = length(dictionary["FunctionNodes"])
    nTerminals = length(dictionary["TerminalNodes"])

    if nFunctions == 0
        error("Nodes configuration file '$jsonFile' must have function nodes")
    end
    if nTerminals == 0
        error("Nodes configuration file '$jsonFile' must have terminal nodes")
    end

    functionSet = Array{FunctionNode}(undef, nFunctions)
    terminalSet = Array{TerminalNode}(undef, nTerminals)

    for i=1:nFunctions
        functionSet[i] = parseFunctionNode(dictionary["FunctionNodes"][i]["Node"])
    end

    for i=1:nTerminals
        terminalSet[i] = parseTerminalNode(dictionary["TerminalNodes"][i]["Node"])
    end

    return functionSet, terminalSet
end # function
