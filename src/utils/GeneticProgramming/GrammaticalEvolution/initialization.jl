
"""
    function growGeneratorProductions(gpExperimentInfo::GEInfo, rng::Random.AbstractRNG,
                    initInd::Array{UInt8}=Array{UInt8}(undef, 0))::GEGenotype

Generates a Grammatical Evolution tree ensuring that the individual is valid having
productions in GEInfo as limit.

# Self-provided Arguments
- `gpExperimentInfo::GEInfo`: information about grammatical evolution.
- `rng::Random.AbstractRNG`: random number generator for random number consistency along an experiment.

!!! note
    `Selfprovided Arguments` are already provided by the library, so only `User Arguments` must be provided.
"""
function growGeneratorProductions(gpExperimentInfo::GEInfo, rng::Random.AbstractRNG,
                initInd::Array{UInt8}=Array{UInt8}(undef, 0))::GEGenotype

    productions::UInt16 = gpExperimentInfo._maxProductions
    gramm = gpExperimentInfo._grammar


    ind = initInd
    if isempty(ind)
        ind = rand(rng, UInt8, productions)
    end

    Root = GERep(getInitialSymbol(gramm))
    stack = [Root]

    # A production is always made due to initial symbol
    actualProductions =  productions - getMinProductions(gramm, getInitialSymbol(gramm)) - 0x2

    actualDepth::UInt8 = 0x0
    symbolsPerDepth = zeros(UInt8, 2)
    symbolsPerDepth[1] = 0x1
    #println("========================================")

    selections = UInt8[]
    i = 1
    while !isempty(stack)
        if symbolsPerDepth[actualDepth + 0x1] == 0x0
            actualDepth += 0x1
        end

        symbolsPerDepth[actualDepth + 0x1] -= 0x1

        node = popfirst!(stack)
        symbol = getSymbol(node)
                #println("symbol->", symbol)
        if !isTerminalSymbol(gramm, symbol)

            #actualProductions = actualProductions + getDepth(gramm, symbol) - 0x1
            actualProductions = actualProductions + getMinProductions(gramm, symbol) - 0x1

            indexes, nIndexes = getPosibleConsequentProductions(gramm, symbol, actualProductions)
"""
            println("ASGKALSGLKASLGKASKLGKLASLK")
            print("  indexes-> ", indexes, "  actualProductions->", actualProductions)
            println(indexes)
            println(actualProductions)

            println("i:",i)
            """

            selected = ind[i] % nIndexes + 0x1
            selected = indexes[selected]


            nChoices = getNConsequent(gramm, symbol)
            ind[i] = ind[i] % (div(256,nChoices)) * nChoices + selected - 0x1

            push!(selections, selected)

            consequent = getConsequent(gramm, symbol, selected)
            if length(symbolsPerDepth) < actualDepth + 0x2
                push!(symbolsPerDepth, getNSymbols(consequent))
            else
                symbolsPerDepth[actualDepth + 0x2] += getNSymbols(consequent)
            end
            actualProductions = actualProductions - getMinProductions(consequent)
            #println("choosed =", selected, "  minproductions: ", getMinProductions(consequent))
            #readline()
            symbols = consequent._symbols
            for j=length(symbols):-1:1
                child = GERep(symbols[j], actualDepth + 0x1)
                pushChild!(node, child)
                push!(stack, child)
            end
            i = i + 1
        end
    end

    return GEGenotype(Root, IntegerGenotype{UInt8}(ind), selections, i-1, true)
end # function



"""
    function growGeneratorDepth(gpExperimentInfo::GEInfo, rng::Random.AbstractRNG,
                    initInd::Array{UInt8}=Array{UInt8}(undef, 0))::GEGenotype

Generates a Grammatical Evolution tree ensuring that the individual is valid having
productions and depth in GEInfo as limit.

# Self-provided Arguments
- `gpExperimentInfo::GEInfo`: information about grammatical evolution.
- `rng::Random.AbstractRNG`: random number generator for random number consistency along an experiment.

!!! note
    `Selfprovided Arguments` are already provided by the library, so only `User Arguments` must be provided.
"""
function growGeneratorDepth(gpExperimentInfo::GEInfo, rng::Random.AbstractRNG,
                        initInd::Array{UInt8}=Array{UInt8}(undef, 0))::GEGenotype

    maxDepth::UInt8 = gpExperimentInfo._maxDepth
    maxProductions::UInt16 = gpExperimentInfo._maxProductions
    gramm = gpExperimentInfo._grammar

    ind = initInd


    if isempty(ind)
        ind = rand(rng, UInt8, maxProductions)
    end

    Root = GERep(getInitialSymbol(gramm))
    stack = [Root]

    actualProductions =  maxProductions - 0x2

    actualDepth::UInt8 = 0x0
    symbolsPerDepth = zeros(UInt8, maxDepth+1)
    symbolsPerDepth[1] = 0x1
    selections = UInt8[]
    i = 1
    while !isempty(stack)
        if symbolsPerDepth[actualDepth + 0x1] == 0x0
            actualDepth += 0x1
        end

        symbolsPerDepth[actualDepth + 0x1] -= 0x1
        node = popfirst!(stack)
        symbol = getSymbol(node)
        if !isTerminalSymbol(gramm, symbol)
            actualProductions = actualProductions + getDepth(gramm, symbol) - 0x1
            indexes, nIndexes = getPosibleConsequentDepth(gramm, symbol, maxDepth-actualDepth, actualProductions)

            selected = ind[i] % nIndexes + 0x1
            selected = indexes[selected]


            nChoices = getNConsequent(gramm, symbol)
            ind[i] = ind[i] % (div(256,nChoices)) * nChoices + selected - 0x1

            push!(selections, selected)

            consequent = getConsequent(gramm, symbol, selected)
            symbolsPerDepth[actualDepth + 0x2] += getNSymbols(consequent)
            actualProductions = actualProductions - getMinProductions(consequent)
            symbols = consequent._symbols
            for j=length(symbols):-1:1
                child = GERep(symbols[j], actualDepth+0x1)
                pushChild!(node, child)
                push!(stack, child)
            end
            i = i + 1
        end
    end


    return GEGenotype(Root, IntegerGenotype(ind), selections, i-1, true)
end # function



"""
    function growGenerator(gpExperimentInfo::GEInfo, rng::Random.AbstractRNG,
                    initInd::Array{UInt8}=Array{UInt8}(undef, 0))::GEGenotype

Generates a Grammatical Evolution tree ensuring that the individual is valid having
productions or productions and depth in GEInfo as limit.

# Self-provided Arguments
- `gpExperimentInfo::GEInfo`: information about grammatical evolution.
- `rng::Random.AbstractRNG`: random number generator for random number consistency along an experiment.

!!! note
    `Selfprovided Arguments` are already provided by the library, so only `User Arguments` must be provided.
"""
function growGenerator(gpExperimentInfo::GEInfo, rng::Random.AbstractRNG,
                        initInd::Array{UInt8}=Array{UInt8}(undef, 0))::GEGenotype

    if gpExperimentInfo._maxDepth < 0
        return growGeneratorProductions(gpExperimentInfo, rng, initInd)
    else
        return growGeneratorDepth(gpExperimentInfo, rng, initInd)
    end
end
precompile(growGenerator, tuple(GEInfo, Random.MersenneTwister, Vector{UInt8}))



"""
    function fullGeneratorProductions(gpExperimentInfo::GEInfo, rng::Random.AbstractRNG,
                    initInd::Array{UInt8}=Array{UInt8}(undef, 0))::GEGenotype

Generates a Grammatical Evolution tree ensuring that the individual is valid having
productions in GEInfo as limit and trying to reach that limit.

# Self-provided Arguments
- `gpExperimentInfo::GEInfo`: information about grammatical evolution.
- `rng::Random.AbstractRNG`: random number generator for random number consistency along an experiment.

!!! note
    `Selfprovided Arguments` are already provided by the library, so only `User Arguments` must be provided.
"""
function fullGeneratorProductions(gpExperimentInfo::GEInfo, rng::Random.AbstractRNG,
                                initInd::Array{UInt8}=Array{UInt8}(undef, 0))::GEGenotype

    productions::UInt16 = gpExperimentInfo._maxProductions
    gramm = gpExperimentInfo._grammar


    ind = initInd
    if isempty(ind)
        ind = rand(rng, UInt8, productions)
    end

    Root = GERep(getInitialSymbol(gramm))
    stack = [Root]

    # A production is always made due to initial symbol
    actualProductions =  productions - getMinProductions(gramm, getInitialSymbol(gramm)) - 0x2

    actualDepth::UInt8 = 0x0
    symbolsPerDepth = zeros(UInt8, 2)
    symbolsPerDepth[1] = 0x1

    selections = UInt8[]
    i = 1
    while !isempty(stack)
        if symbolsPerDepth[actualDepth + 0x1] == 0x0
            actualDepth += 0x1
        end

        symbolsPerDepth[actualDepth + 0x1] -= 0x1

        node = popfirst!(stack)
        symbol = getSymbol(node)
        if !isTerminalSymbol(gramm, symbol)
            #actualProductions = actualProductions + getDepth(gramm, symbol) - 0x1
            actualProductions = actualProductions + getMinProductions(gramm, symbol) - 0x1
            indexes, nIndexes = getPosibleRecursiveProductions(gramm, symbol, actualProductions)

            selected = ind[i] % nIndexes + 0x1
            selected = indexes[selected]


            nChoices = getNConsequent(gramm, symbol)
            ind[i] = ind[i] % (div(256,nChoices)) * nChoices + selected - 0x1


            push!(selections, selected)

            consequent = getConsequent(gramm, symbol, selected)
            if length(symbolsPerDepth) < actualDepth + 0x2
                push!(symbolsPerDepth, getNSymbols(consequent))
            else
                symbolsPerDepth[actualDepth + 0x2] += getNSymbols(consequent)
            end
            actualProductions = actualProductions - getMinProductions(consequent)
            symbols = consequent._symbols
            for j=length(symbols):-1:1
                child = GERep(symbols[j], actualDepth + 0x1)
                pushChild!(node, child)
                push!(stack, child)
            end
            i = i + 1
        end
    end

    return GEGenotype(Root, IntegerGenotype(ind), selections, i-1, true)
end # function



"""
    function fullGeneratorDepth(gpExperimentInfo::GEInfo, rng::Random.AbstractRNG,
                    initInd::Array{UInt8}=Array{UInt8}(undef, 0))::GEGenotype

Generates a Grammatical Evolution tree ensuring that the individual is valid having
productions and depth in GEInfo as limit and trying to reach that limit.

# Self-provided Arguments
- `gpExperimentInfo::GEInfo`: information about grammatical evolution.
- `rng::Random.AbstractRNG`: random number generator for random number consistency along an experiment.

!!! note
    `Selfprovided Arguments` are already provided by the library, so only `User Arguments` must be provided.
"""
function fullGeneratorDepth(gpExperimentInfo::GEInfo, rng::Random.AbstractRNG,
                            initInd::Array{UInt8}=Array{UInt8}(undef, 0))::GEGenotype

    maxDepth::UInt8 = gpExperimentInfo._maxDepth
    maxProductions::UInt16 = gpExperimentInfo._maxProductions
    gramm = gpExperimentInfo._grammar

    ind = initInd
    if isempty(ind)
        ind = rand(rng, UInt8, maxProductions)
    end

    Root = GERep(getInitialSymbol(gramm))
    stack = [Root]

    actualProductions =  maxProductions - 0x2
    # A production is always made due to initial symbol
    actualDepth::UInt8 = 0x0
    symbolsPerDepth = zeros(UInt8, maxDepth+1)
    symbolsPerDepth[1] = 0x1
    selections = UInt8[]
    i = 1
    while !isempty(stack)
        if symbolsPerDepth[actualDepth+0x1] == 0x0
            actualDepth += 0x1
        end

        symbolsPerDepth[actualDepth+0x1] -= 0x1
        node = popfirst!(stack)
        symbol = getSymbol(node)

        if !isTerminalSymbol(gramm, symbol)
            leftDepth = maxDepth-actualDepth
            actualProductions = actualProductions + getDepth(gramm, symbol) - 0x1

            indexes, nIndexes = getPosibleRecursiveDepth(gramm, symbol, maxDepth-actualDepth, actualProductions)

            selected = ind[i] % nIndexes + 0x1
            selected = indexes[selected]


            nChoices = getNConsequent(gramm, symbol)
            ind[i] = ind[i] % (div(256,nChoices)) * nChoices + selected - 0x1

            push!(selections, selected)

            consequent = getConsequent(gramm, symbol, selected)
            symbolsPerDepth[actualDepth + 0x2] += getNSymbols(consequent)
            actualProductions = actualProductions - getMinProductions(consequent)
            symbols = consequent._symbols
            for j=length(symbols):-1:1
                child = GERep(symbols[j], actualDepth+0x1)
                pushChild!(node, child)
                push!(stack, child)
            end
            i = i + 1
        end
    end


    return GEGenotype(Root, IntegerGenotype(ind), selections, i-1, true)
end # function



"""
    function fullGenerator(gpExperimentInfo::GEInfo, rng::Random.AbstractRNG,
                    initInd::Array{UInt8}=Array{UInt8}(undef, 0))::GEGenotype

Generates a Grammatical Evolution tree ensuring that the individual is valid having
productions or productions and depth in GEInfo as limit and trying to reach that limit.

# Self-provided Arguments
- `gpExperimentInfo::GEInfo`: information about grammatical evolution.
- `rng::Random.AbstractRNG`: random number generator for random number consistency along an experiment.

!!! note
    `Selfprovided Arguments` are already provided by the library, so only `User Arguments` must be provided.
"""
function fullGenerator(gpExperimentInfo::GEInfo, rng::Random.AbstractRNG,
                        initInd::Array{UInt8}=Array{UInt8}(undef, 0))::GEGenotype

    if gpExperimentInfo._maxDepth < 0
        return fullGeneratorProductions(gpExperimentInfo, rng, initInd)
    else
        return fullGeneratorDepth(gpExperimentInfo, rng, initInd)
    end
end

precompile(growGenerator, tuple(GEInfo, Random.MersenneTwister, Vector{UInt8}))



"""
    function generateTreeProductions(gpExperimentInfo::GEInfo, rng::Random.AbstractRNG,
                    codons::Array{UInt8})::GEGenotype

Generates a Grammatical Evolution tree from codons having productions in GEInfo as limit, if
the limit is overcome, then the individual is not valid.

# Self-provided Arguments
- `gpExperimentInfo::GEInfo`: information about grammatical evolution.
- `rng::Random.AbstractRNG`: random number generator for random number consistency along an experiment.

# User Arguments
- `codons::Array{UInt8}`: array with the proteins that represents a number related with the selections to be done.

!!! note
    `Selfprovided Arguments` are already provided by the library, so only `User Arguments` must be provided.
"""
function generateTreeProductions(gpExperimentInfo::GEInfo, rng::Random.AbstractRNG,
                                codons::Array{UInt8})::GEGenotype

    gramm = gpExperimentInfo._grammar
    maxProductions = gpExperimentInfo._maxProductions

    Root = GERep(getInitialSymbol(gramm))
    stack = [Root]
    selections = UInt8[]

    actualDepth::UInt8 = 0x0
    symbolsPerDepth = zeros(UInt8, 2)
    symbolsPerDepth[1] = 0x1

    i = 1
    while !isempty(stack) && i<=maxProductions
        if symbolsPerDepth[actualDepth + 0x1] == 0
            actualDepth += 0x1
        end

        symbolsPerDepth[actualDepth + 0x1] -= 0x1

        node = popfirst!(stack)
        symbol = getSymbol(node)
        if !isTerminalSymbol(gramm, symbol)

            selected = codons[i] % getNConsequent(gramm, symbol) + 0x1

            push!(selections, selected)
            consequent = getConsequent(gramm, symbol, selected)
            if length(symbolsPerDepth) < actualDepth + 0x2
                push!(symbolsPerDepth, getNSymbols(consequent))
            else
                symbolsPerDepth[actualDepth + 0x2] += getNSymbols(consequent)
            end
            symbols = consequent._symbols
            for j=length(symbols):-1:1
                child = GERep(symbols[j], actualDepth + 0x1)
                pushChild!(node, child)
                push!(stack, child)
            end
            i = i + 1
        end
    end
    if i > maxProductions
        return GEGenotype(Root, IntegerGenotype{UInt8}(codons), selections, i-1, false)
    else
        return GEGenotype(Root, IntegerGenotype{UInt8}(codons), selections, i-1, true)
    end
end



"""
    function generateTreeDepth(gpExperimentInfo::GEInfo, rng::Random.AbstractRNG,
                    codons::Array{UInt8})::GEGenotype

Generates a Grammatical Evolution tree from codons having productions and depth
in GEInfo as limit, if the limit is overcome, then the individual is not valid.

# Self-provided Arguments
- `gpExperimentInfo::GEInfo`: information about grammatical evolution.
- `rng::Random.AbstractRNG`: random number generator for random number consistency along an experiment.

# User Arguments
- `codons::Array{UInt8}`: array with the proteins that represents a number related with the selections to be done.

!!! note
    `Selfprovided Arguments` are already provided by the library, so only `User Arguments` must be provided.
"""
function generateTreeDepth(gpExperimentInfo::GEInfo, rng::Random.AbstractRNG,
                                codons::Array{UInt8})::GEGenotype

    gramm = gpExperimentInfo._grammar
    maxProductions = gpExperimentInfo._maxProductions
    maxDepth = gpExperimentInfo._maxDepth

    Root = GERep(getInitialSymbol(gramm))
    stack = [Root]
    selections = UInt8[]

    actualDepth::UInt8 = 0x0
    symbolsPerDepth = zeros(UInt8, 2)
    symbolsPerDepth[1] = 0x1

    i = 1
    while !isempty(stack) && i<=maxProductions && actualDepth <= maxDepth
        if symbolsPerDepth[actualDepth + 0x1] == 0
            actualDepth += 0x1
        end

        symbolsPerDepth[actualDepth + 0x1] -= 0x1

        node = popfirst!(stack)
        symbol = getSymbol(node)
        if !isTerminalSymbol(gramm, symbol)

            selected = codons[i] % getNConsequent(gramm, symbol) + 0x1

            push!(selections, selected)
            consequent = getConsequent(gramm, symbol, selected)
            if length(symbolsPerDepth) < actualDepth + 0x2
                push!(symbolsPerDepth, getNSymbols(consequent))
            else
                symbolsPerDepth[actualDepth + 0x2] += getNSymbols(consequent)
            end
            symbols = consequent._symbols
            for j=length(symbols):-1:1
                child = GERep(symbols[j], actualDepth + 0x1)
                pushChild!(node, child)
                push!(stack, child)
            end
            i = i + 1
        end
    end
    if i > maxProductions || actualDepth > maxDepth
        return GEGenotype(Root, IntegerGenotype{UInt8}(codons), selections, i-1, false)
    else
        return GEGenotype(Root, IntegerGenotype{UInt8}(codons), selections, i-1, true)
    end
end



"""
    function generateTree(gpExperimentInfo::GEInfo, rng::Random.AbstractRNG,
                                    codons::Array{UInt8})::GEGenotype

Generates a Grammatical Evolution tree ensuring that the individual is valid having
productions or productions and depth in GEInfo as limit and trying to reach that limit.

# Self-provided Arguments
- `gpExperimentInfo::GEInfo`: information about grammatical evolution.
- `rng::Random.AbstractRNG`: random number generator for random number consistency along an experiment.

# User Arguments
- `codons::Array{UInt8}`: array with the proteins that represents a number related with the selections to be done.

!!! note
    `Selfprovided Arguments` are already provided by the library, so only `User Arguments` must be provided.
"""
function generateTree(gpExperimentInfo::GEInfo, rng::Random.AbstractRNG,
                                codons::Array{UInt8})::GEGenotype

    if gpExperimentInfo._maxDepth < 0
        return generateTreeProductions(gpExperimentInfo, rng, codons)
    else
        return generateTreeDepth(gpExperimentInfo, rng, codons)
    end
end



"""
    rampedHalfHalfGenerator(gpExperimentInfo::GEInfo, popSize::UInt32,
                            rng::Random.AbstractRNG, RHHFactor::Float64 = 0.5)

Initializes a population for a GP problem by the \"ramped half and half\" method,
which creates part of it using the full method, and the other part using the grow
method.

`Self-provided Arguments` are provided by the library, so only `User Arguments` must be provided.

# Self-provided Arguments
- `gpExperimentInfo::GEInfo`: information about the GP experiment.
- `popSize::UInt32`: size of the population that is going to be created, that is
    to say, the number of individuals of the population.
- `rng::Random.AbstractRNG`: random number generator for random number consistency
    along an experiment.

# User arguments
- `RHHFactor::Float64 = 0.5`: percentage of the population that is going to
    be created by the \"full\" method, the remaining percentage will be created by
    the \"grow\" method.

# Returns
A population of GP individuals generated by the \"ramped half and half\" method.
"""
function rampedHalfHalfGenerator(gpExperimentInfo::GEInfo, popSize::UInt32,
                                 rng::Random.AbstractRNG, RHHFactor::Float64 = 0.5)

    population = Array{GEGenotype}(undef, popSize)
    N = popSize - round(Integer, popSize * RHHFactor)

    for i = 1:(popSize-N)
        population[i] = fullGenerator(gpExperimentInfo, rng)
    end

    for i = (popSize-N+1):popSize
        population[i] = growGenerator(gpExperimentInfo, rng)
    end

    return Random.shuffle(rng, population)
end # function


# TODO Cruce basado en probabilidad.
"""

function geGenerator(gpExperimentInfo::GEInfo, rng::Random.AbstractRNG, initInd::Array{Integer}=Array{Integer}(undef, 0))

    productions = gpExperimentInfo._maxProductions
    gramm = gpExperimentInfo._grammar
    growRatio = gpExperimentInfo._growRatio

    ind = initInd
    if length(ind) == 0
        ind = [rand(rng, UInt16) for x=1:productions]
    end

    Root = GERep(gramm._S)
    stack = [Root]
    auxStack = [getSymbol(Root)]
    # A production is always made due to initial symbol
    actualProductions = productions - 2

    actualDepth = 0
    symbolsPerDepth = zeros(UInt8, 2)
    symbolsPerDepth[1] = 1

    selections = []
    i = 1
    while !isempty(stack)
        if symbolsPerDepth[actualDepth + 1] == 0
            actualDepth += 1
        end

        symbolsPerDepth[actualDepth + 1] -= 1

        node = popfirst!(stack)
        symbol = getSymbol(node)
        if !isTerminalSymbol(gramm, symbol)
            if actualProductions <= 1
                actualProductions = actualProductions + getDepth(gramm, symbol) - 1
                indexes = getPosibleConsequentProductions(gramm, symbol, actualProductions)
            else
                actualProductions = actualProductions + getDepth(gramm, symbol) - 1

                if rand(rng) < ratio

                end
            end

            indexes = getPosibleConsequentProductions(gramm, symbol, actualProductions)

            nIndexes = length(indexes)
            selected = ind[i] % nIndexes + 1
            selected = indexes[selected]

            nChoices = getNConsequent(gramm, symbol)
            ind[i] = ind[i] % (256/nChoices) * nChoices + selected

            push!(selections, selected)
            consequent = getConsequent(gramm, symbol, selected)
            if length(symbolsPerDepth) < actualDepth + 2
                push!(symbolsPerDepth, getNSymbols(consequent))
            else
                symbolsPerDepth[actualDepth + 2] += getNSymbols(consequent)
            end
            actualProductions = actualProductions - getMinProductions(consequent)
            symbols = consequent._symbols
            for j=1:length(symbols)
                child = GERep(symbols[j], actualDepth + 1)
                pushChild!(node, child)
                push!(stack, child)
                push!(auxStack, symbols[j])
            end
            i = i + 1
        end
    end

    return GEGenotype(Root, IntegerGenotype(ind), selections, i-1)
end # function
"""
