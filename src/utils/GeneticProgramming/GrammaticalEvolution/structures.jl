#### GEInfo #########

"
Auxiliary structure that keeps some generic information for Grammatical Evolution experiments.

# Fields
- `_grammar::Grammar`: grammar that will be used. This includes terminal and non-terminal
    symbols, production rules and the initial symbol.
- `_maxProductions::Int16`: maximum number of productions permitted to generate
    trees.
- `_maxDepth::Int16`: maximum tree depth permitted.
- `_variables::Array{String}`: array that contains the names of the variables of
    the problem.
- `varValues::Array{NamedTuple}`: values for the variables of the problem.

See also: [`GPExperimentInfo`](@ref), [`Grammar`](@ref)
"
struct GEInfo <: GPExperimentInfo
    _grammar::Grammar
    _maxProductions::Int16
    _maxDepth::Int16
    _variables::Array{String}
    _varValues::Array{NamedTuple}
end # struct



"""
    setGEInfo(N::Array{String}, T::Array{String}, P::Array{String}, S::String,
              variables::Array{String}, varValues...; genj::GenJulia = GenJ,
              maxProductions::Integer = 15, maxDepth::Integer = -1)

Sets the information about a Grammatical Evolution problem.
This function constructs a structure of type `GEInfo` and adds it to the GP
experiment information field of the experiment information of the main structure.

# Arguments
- `N::Array{String}`: array that contains the symbols of non-terminal grammatical
    expressions.
- `T::Array{String}`: array that contains the symbols of terminal grammatical
    expressions.
- `P::Array{String}`: array that contains the production rules.
- `S:String`: initial symbol from which the expressions are generated.
- `variables::Array{String}`: array that contains the name of the variables of the problem.
- `varValues`: values for the variables of the problem. These values must be
    arrays of the same size containing the actual values for each variable. If
    the problem does not have any variable, this argument shall not be given by
    the user. (See Examples)

# Keyword Arguments
- `maxProductions::Integer = 15`: maximum number of productions permitted.
- `maxDepth::Integer = -1`: maximum tree depth permitted.
- `genj::GenJulia = GenJ`: the main structure. For `code user`: don't modify
    the default value unless multiple experiments are going to be run.

# Examples
Declaring the Grammar and setting the arguments by default for a problem with
2 variables (\"x\" and \"y\").
```jldoctest
julia> N=["expr","op", "var"]
3-element Array{String,1}:
 "expr"
 "op"
 "var"

julia> T=["x", "y", "+", "-", "/", "*", "(", ")"]
8-element Array{String,1}:
 "x"
 "y"
 "+"
 "-"
 "/"
 "*"
 "("
 ")"

julia> P=[
    "<expr> -> (<expr> <op> <expr>)
             | <var>",

    "<op> -> +
           | -
           | /
           | *",

    "<var> -> x
            | y"
]
3-element Array{String,1}:
 "<expr> -> (<expr> <op> <expr>) | <var>"
 "<op> -> + | - | / | *"
 "<var> -> x | y"

julia> S="expr"
"expr"

julia> xValues = collect(-5:0.5:5)
21-element Array{Float64,1}:
[...]

julia> yValues = collect(0:0.5:10)
21-element Array{Float64,1}:
[...]

julia> setGEInfo(N, T, P, S, ["x", "y"], xValues, yValues)
[...]
```

Setting a maximum number of productions of 20.
```jldoctest
julia> setGEInfo(N, T, P, S, ["x", "y"], xValues, yValues, maxProductions=20)
[...]
```

Setting a maximum tree depth of 5.
```jldoctest
julia> setGEInfo(N, T, P, S, ["x", "y"], xValues, yValues, maxProductions=0, maxDepth=5)
[...]
```

When setting a maximum number of production rules or a maximum tree depth,
take in consideration that those two cannot be set a the same time, otherwise
an error will be thrown.

Setting a maximum tree depth of 5 without setting the maximum number of productions to
0.
```jldoctest
julia> setGEInfo(N, T, P, S, ["x", "y"], xValues, yValues, maxProductions=20, maxDepth=5)
ERROR: Either maxDepth or maxProduction must be set, but not both. By default,
    maxProductions is 15, if you want to use maxDepth, set maxProductions to 0 or below.
    [...]
```

Also, either if you set `maxProductions` to a number lower than 6 or `maxDepth` to a
number lower than 3, a warning will be displayed saying that if the Grammar is
long, generated trees might be too similar with so few productions or small depth
or incorrect due to no termination.

```jldoctest
julia> #Setting a maximum tree depth of 5
julia> setGEInfo(N, T, P, S, ["x", "y"], xValues, yValues, maxProductions=4)
Warning: maxProductions have been set to 1, if your grammar is long, grammatical
    trees will be too similar or, in some cases, incorrect due to no termination
    [...]
```

See also: [`setCGPInfo`](@ref), [`setSTGPInfo`](@ref), [`setGEPInfo`](@ref),
[`setGPExperimentInfo`](@ref)
"""
function setGEInfo(N::Array{String}, T::Array{String}, P::Array{String}, S::String,
                   variables::Array{String}, varValues...; genj::GenJulia = GenJ,
                   maxProductions::Integer = 15, maxDepth::Integer = -1)

    if maxDepth > 0 && maxProductions < 0
        error("If maxDepth is set, maxProduction must be set. By
               default, maxProductions is 15, if you want to use maxDepth, set
               maxProductions to a higher number.")
    end
    if maxDepth <= 0 && maxProductions <= 0
        error("Either maxDepth or maxProduction must be set. By
               default, maxProductions is 15, if you want to use maxDepth, set
               maxProductions to a higher number.")
    end

    if 0 < maxProductions < 6
        @warn "maxProductions have been set to $maxProductions, if your grammar
               is long, grammatical trees will be too similar or, in some cases,
               incorrect due to no termination"
    end

    if 0 < maxDepth < 3
        @warn "maxDepth have been set to $maxDepth, if your grammar is long,
               grammatical trees will be too similar or, in some cases, incorrect
               due to no termination"
    end

    # Existance of every variable as a terminal node is checked
    for i=1:length(variables)
        check = false
        for j=1:length(N)
            if variables[i] == T[j]
                check = true
                break
            end
        end
        if !check
            error("Variable $(variables[i]) isn't found in the terminal set")
        end
    end

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

    grammar = createGrammar(N, T, P, S)
    setGPExperimentInfo(GEInfo(grammar, maxProductions, maxDepth, variables, valuesDict), genj=genj)
end # function



#### GEREP ##########
"
Structure that is the representantion of an individual in Grammatical Evolution,
which is a tree.

# Fields
- `_symbol::UInt16`: symbol in the grammar.
- `_depth::UInt8`: actual depth of the node in the tree.
- `_children::Array{GERep}`: children of symbol if it is a non terminal.

See also: [`GEGenotype`](@ref)
"
mutable struct GERep
    _symbol::UInt16
    _depth::UInt8
    _children::Array

    GERep(symbol::UInt16) = new(symbol, 0, Array{GERep}(undef, 0))
    GERep(symbol::UInt16, depth::UInt8) = new(symbol, depth, Array{GERep}(undef, 0))
end



"""
    getSymbol(tree::GERep)::UInt16

Returns the symbol stored.
"""
getSymbol(tree::GERep)::UInt16 = tree._symbol



"""
    getDepth(tree::GERep)::UInt8

Returns the depth of the node in the tree.
"""
getDepth(tree::GERep)::UInt8 = tree._depth



"""
    getChildren(tree::GERep)::Array{GERep}

Returns the array of children.
"""
getChildren(tree::GERep)::Array{GERep} = tree._children



"""
    setDepth!(tree::GERep, value)

Sets the depth of the node in the tree.
"""
setDepth!(tree::GERep, value) = tree.depth = depth



"""
    setChildren!(tree::GERep, children::Array{GERep})

Sets the children of the node.
"""
setChildren!(tree::GERep, children::Array{GERep}) = tree._children = children



"""
    pushChild!(tree::GERep, child::GERep)

Introduce a child in the array of children.
"""
pushChild!(tree::GERep, child::GERep) = push!(getChildren(tree), child)



"""
    getNChildren(tree::GERep)::Int

Returns the number of children.
"""
getNChildren(tree::GERep)::Int = length(getChildren(tree))



"""
    isLeaf(tree::GERep)::Bool

Checks whether the node is a leaf or not.
"""
isLeaf(tree::GERep)::Bool = getNChildren(tree::GERep) == 0



"""
    getHeights(tree::GERep)

Obtains the heights of the nodes in preorder.
!!! warning
    DO NOT USE, it is still experimental.
"""
function getHeights(tree::GERep)

    representation = getPreOrder(tree)
    lenRep = length(representation)
    heights = Array{UInt16}(undef, lenRep)
    heights[end] = 0
    stack = [lenRep]
    currIndex = lenRep - 1

    while currIndex > 0

        if isLeaf(representation[currIndex])
            heights[currIndex] = 0
        else
            childrenIndexes = Array{UInt8}(undef, 0)
            for i=1:getNChildren(representation[currIndex])
                push!(childrenIndexes, pop!(stack))
            end
            heights[currIndex] = maximum(heights[childrenIndexes]) + 1
        end

        push!(stack, currIndex)
        currIndex -= 1
    end
    return heights
end



"""
    changeNodes!(tree1::GERep, tree2::GERep)

Interchange the given nodes.
"""
function changeNodes!(tree1::GERep, tree2::GERep)
    tree1._symbol, tree2._symbol = tree2._symbol, tree1._symbol
    tree1._children, tree2._children = tree2._children, tree1._children
    tree1._depth, tree2._depth = tree2._depth, tree1._depth
end



"""
    copyTree(tree::GERep)::GERep

Makes a copy of the tree.
"""
function copyTree(tree::GERep)::GERep

    stack = [tree]
    newTree = GERep(tree._symbol, tree._depth)
    copyStack = [newTree]

    while !isempty(stack)
        node = popfirst!(stack)
        newnode = popfirst!(copyStack)
        if !isLeaf(node)
            children = getChildren(node)
            for i in eachindex(children)
                newChild = GERep(children[i]._symbol, children[i]._depth)
                pushChild!(newnode, newChild)
                push!(stack, children[i])
                push!(copyStack, newChild)
            end
        end
    end
    return newTree
end



"""
    printTree(tree::GERep, gramm::Grammar)

Print the tree formated in the current output.
"""
function printTree(tree::GERep, gramm::Grammar)
    stack = [tree]
    result = []
    depth = 0

    function printRecursive(node, depth)
        for i=1:depth-1
            print("   ")
        end
        print("|--")
        if isLeaf(node)
            println(getRepresentation(gramm, node))
        else
            println(getRepresentation(gramm, node))
            for i=getNChildren(node):-1:1
                printRecursive(getChildren(node)[i], depth + 1)
            end
        end
    end
    println(getRepresentation(gramm, tree))
    for i=getNChildren(tree):-1:1
        printRecursive(getChildren(tree)[i], 1)
    end
    return nothing
end



"""
    getPreOrder(tree::GERep, onlyNonTerminal::Bool=false)

Returns the given tree as an array in preorder.
"""
function getPreOrder(tree::GERep, onlyNonTerminal::Bool=false)

    stack = [tree]
    preOrder = Array{GERep}(undef, 0)

    while !isempty(stack)
        node = popfirst!(stack)
        if isLeaf(node)
            if !onlyNonTerminal
                push!(preOrder, node)
            end
        else
            push!(preOrder, node)
            children = getChildren(node)
            nChildren = length(children)
            for i=nChildren:-1:1
                pushfirst!(stack, children[i])
            end
        end
    end
    return preOrder
end



"""
    countNonTerminal(tree::GERep)

Returns the number of non terminals in the tree.
"""
function countNonTerminal(tree::GERep)
    stack = [tree]
    count = 0
    while !isempty(stack)
        node = popfirst!(stack)

        if !isLeaf(node)
            count = count + 1
            children = getChildren(node)
            nChildren = length(children)
            for i=nChildren:-1:1
                pushfirst!(stack, children[i])
            end
        end
    end
    return count
end



"""
    getRepresentation(gramm::Grammar, tree::GERep)

Interface for `getRepresentation(gramm::Grammar, id::UInt16)`
"""
function getRepresentation(gramm::Grammar, tree::GERep)
    getRepresentation(gramm, getSymbol(tree))
end



"Main struct for Grammatical Evolution genotypes used in GP."
struct GEGenotype <: GPGenotype
    _tree::GERep
    _ind::IntegerGenotype
    _selections::Array{UInt8}
    _productions::UInt16
    _valid::Bool
end # struct



"""
    pruneProtein(genotype1, genotype2)::Tuple{IntegerGenotype{UInt8}, Array{UInt8}, IntegerGenotype{UInt8}, Array{UInt8}}

Perfoms a prune dividing the codons in two, the useful part and the introns for each
genotype. Returning -> useful1, introns1, useful2, introns2
"""
function pruneProtein(genotype1, genotype2)::Tuple{IntegerGenotype{UInt8}, Array{UInt8}, IntegerGenotype{UInt8}, Array{UInt8}}
    protein1 = genotype1._ind
    len1 = genotype1._productions
    protein2 = genotype2._ind
    len2 = genotype2._productions

    maxlen = len1
    if len2 > len1
        maxLen = len2
    end
    subProtein1 = IntegerGenotype{UInt8}(protein1._representation[1:maxlen])
    introns1 = protein1._representation[maxlen+1:end]

    subProtein2 = IntegerGenotype{UInt8}(protein2._representation[1:maxlen])
    introns2 = protein2._representation[maxlen+1:end]

    return subProtein1, introns1, subProtein2, introns2
end



"""
    pruneProtein(genotype1)::Tuple{IntegerGenotype{UInt8}, Array{UInt8}}

Perfoms a prune dividing the codons in two, the useful part and the introns for
genotype. Returning -> useful, introns
"""
function pruneProtein(genotype)::Tuple{IntegerGenotype{UInt8}, Array{UInt8}}

    protein = genotype._ind
    len = genotype._productions

    subProtein = IntegerGenotype(protein._representation[1:len])
    introns = protein._representation[len:end]

    return subProtein, introns
end



"""
    copyGenotype(geGenotype::GEGenotype)::GEGenotype

Returns a copy of the genotype.
"""
function copyGenotype(geGenotype::GEGenotype)::GEGenotype
    tree = copyTree(geGenotype._tree)
    ind = copyGenotype(geGenotype._ind)
    selections = copy(geGenotype._selections)
    productions = geGenotype._productions
    valid = geGenotype._valid
    GEGenotype(tree, ind, selections, productions, valid)
end
