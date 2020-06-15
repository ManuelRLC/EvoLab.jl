
#### CONSEQUENT ###########
"
Structure that keeps the information related to one of the consequents of a production rule.

# Fields
- `_symbols::Array{UInt16}`: list with the symbols (in order) that represents the consequent.
- `_depth::Int16`: minimum depth that the generate tree would have, considering depth as the maximum
    of the minimum depths of the symbols.
- `_minProductions::Int16`: the number of productions that must be mandatory done through this consequent.
- `_recursive::Bool`: whether the consequent is recursive or not, meaning that the consequent
    has a symbol that is equal to its antecedent or there is production rule derivated that
    fulfill this statement.
- `_nSymbols::UInt8`: number of symbols in the consequent.

See also: [`Grammar`](@ref), [`ProductionRule`](@ref)
"
mutable struct Consequent
    _symbols::Array{UInt16}
    _depth::Int16
    _minProductions::Int16
    _recursive::Bool
    _nSymbols::UInt8

    Consequent(symbols::Array{UInt16}) = new(symbols, -32000, 32000, false, length(symbols))
    Consequent(symbols::Array{UInt16}, depth::Int16) = new(symbols, depth, 32000, false, length(symbols))
end


"""
    getNSymbols(genotype::Genotype)::UInt8

Returns the number of symbol of the consequent.
"""
getNSymbols(consequent::Consequent)::UInt8 = consequent._nSymbols


"""
    getDepth(consequent::Consequent)::Int16

Returns the the maximum of the minimum depths of the symbols.
"""
getDepth(consequent::Consequent)::Int16 = consequent._depth


"""
    isRecursive(consequent::Consequent)::Bool

Returns whether is recursive or not.
"""
isRecursive(consequent::Consequent)::Bool = consequent._recursive


"""
    getMinProductions(consequent::Consequent)::Int16

Returns the number of productions that must be mandatory done through this consequent.
"""
getMinProductions(consequent::Consequent)::Int16 = consequent._minProductions



#### PRODUCTION RULE ###########

"
Structure that keeps the information related to a production rule that is identified by antecedent.

# Fields
- `_antecedent::UInt16`: Non-terminal symbol.
- `_consequent::Array{Consequent}`
- `_depth::Int16`: depth that represent the minimum of consequents depth.
- `_nConsequent::UInt8`: number of consequents.

See also: [`Grammar`](@ref), [`Consequent`](@ref)
"
mutable struct ProductionRule
    _antecedent::UInt16
    _consequent::Array{Consequent}
    _depth::Int16
    _nConsequent::UInt8

    ProductionRule(antecedent::Integer, consequent::Array{Consequent}) = new(antecedent, consequent, -32000, length(consequent))
end


"""
    hasDepth(productionRule::ProductionRule)::Bool

Returns whether the depth is already set or not.
"""
hasDepth(productionRule::ProductionRule)::Bool = productionRule._depth != -32000


"""
    getNConsequent(productionRule::ProductionRule)::UInt8

Returns the number of consequent that the production rule has.
"""
getNConsequent(productionRule::ProductionRule)::UInt8 = productionRule._nConsequent


"""
    getNRules(productionRule::ProductionRule)::UInt8

Returns the number of consequent that the production rule has.
"""
getNRules(productionRule::ProductionRule)::UInt8 = getNConsequent(productionRule)


"""
    getDepth(productionRule::ProductionRule)::Int16

Returns the depth that represent the minimum of consequents depth.
"""
getDepth(productionRule::ProductionRule)::Int16 = productionRule._depth


"""
    getConsequent(productionRule::ProductionRule)::Consequent

Returns the consequent associated with index.
"""
getConsequent(productionRule::ProductionRule, index::UInt8)::Consequent = productionRule._consequent[index]


"""
    getPosibleConsequentProductions(productionRule::ProductionRule, productions::UInt16=0xffff)::Tuple{Array{UInt8}, UInt8}

Obtains the consequents indexes that have less or equal minimum productions than the productions specified.
"""
function getPosibleConsequentProductions(productionRule::ProductionRule, productions::UInt16=0xffff)::Tuple{Array{UInt8}, UInt8}
    index = UInt8[]
    count::UInt8 = 0x0
    for i=eachindex(productionRule._consequent)
        consequent = productionRule._consequent[i]
        if getMinProductions(consequent) <= productions
            push!(index, i)
            count += 0x1
        end
    end
    return index, count
end


"""
    getPosibleConsequentProductions(productionRule::ProductionRule, productions::UInt16=0xffff)::Tuple{Array{UInt8}, UInt8}

Obtains the consequents indexes that have less or equal minimum productions than the productions specified and are recursives.
"""
function getPosibleRecursiveProductions(productionRule::ProductionRule, productions::UInt16=0xffff)::Tuple{Array{UInt8}, UInt8}
    index = UInt8[]
    count::UInt8 = 0x0
    for i=eachindex(productionRule._consequent)
        consequent = productionRule._consequent[i]
        if getMinProductions(consequent) <= productions && isRecursive(consequent)
            push!(index, i)
            count += 0x1
        end
    end

    if isempty(index)
        index, count = getPosibleConsequentProductions(productionRule, productions)
    end
    return index, count
end


"""
    getPosibleConsequentDepth(productionRule::ProductionRule, depth::UInt8=0xffff, productions::UInt16=0xffff)::Tuple{Array{UInt8}, UInt8}

Obtains the consequents indexes that have less or equal minimum productions than the productions specified and
have less minDepth than the depth specified.
"""
function getPosibleConsequentDepth(productionRule::ProductionRule, depth::UInt8=0xffff, productions::UInt16=0xffff)::Tuple{Array{UInt8}, UInt8}
    index = UInt8[]
    count::UInt8 = 0x0
    for i=eachindex(productionRule._consequent)
        consequent = productionRule._consequent[i]
        if getDepth(consequent) < depth && getMinProductions(consequent) <= productions
            push!(index, i)
            count += 0x1
        end
    end
    return index, count
end

"""
    getPosibleRecursiveDepth(productionRule::ProductionRule, depth::UInt8=0xffff, productions::UInt16=0xffff)::Tuple{Array{UInt8}, UInt8}

Obtains the consequents indexes that have less or equal minimum productions than the productions specified,
have less minDepth than the depth specified and are recursive.
"""
function getPosibleRecursiveDepth(productionRule::ProductionRule, depth::UInt8=0xff, productions::UInt16=0xffff)::Tuple{Array{UInt8}, UInt8}
    index = UInt8[]
    count::UInt8 = 0x0
    for i=eachindex(productionRule._consequent)
        consequent = productionRule._consequent[i]
        if (getDepth(consequent) < depth
            && isRecursive(consequent)
            && getMinProductions(consequent) <= productions)
            push!(index, i)
            count += 0x1
        end
    end
    if isempty(index)
        index, count = getPosibleConsequentDepth(productionRule, depth, productions)
    end
    return index, count
end





#### GRAMMAR #########
"
Structure that keeps the information related to the grammar.

# Fields
- `_N::Array{String}`: non-terminal set.
- `_T::Array{String}`: terminal set.
- `_P::Array{ProductionRule}`: storages all the info about the production rules.
- `_S::String`: initial symbol of the grammar.
- `_nProductionRules::UInt16`: number of production rules

!!! note
    **Symbols** are `UInt`, that represent an index of the terminal array if
    symbol > 1000 or an index of the non terminal if symbol <= 1000
See also: [`Consequent`](@ref), [`ProductionRule`](@ref)
"
struct Grammar
    _N::Array{String}
    _T::Array{String}
    _P::Array{ProductionRule}
    _S::UInt16
    _nProductionRules::UInt16

    Grammar(N, T, P, S) = new(N, T, P, convert(UInt16, findfirst(x->x==S, N)), length(P))
end # struct
export Grammar


"""
    getInitialSymbol(gramm::Grammar)::UInt16

Returns the first symbol of the grammar.
"""
getInitialSymbol(gramm::Grammar)::UInt16 = gramm._S


"""
    ggetProductionRule(gramm::Grammar, id::UInt16)::ProductionRule

Obtains the production rule assoacited to id, that in this context is the same as
non terminal symbol.
"""
getProductionRule(gramm::Grammar, id::UInt16)::ProductionRule = gramm._P[id]



"""
    getDepth(gramm::Grammar, id::UInt16)::Int16

A interface for `getDepth(productionRule::ProductionRule)`.
"""
getDepth(gramm::Grammar, id::UInt16)::Int16 = getDepth(getProductionRule(gramm, id))


"""
    getRepresentation(gramm::Grammar, id::UInt16)::String

Returns the correspondence of a numeric symbol, a string.
"""
getRepresentation(gramm::Grammar, id::UInt16)::String = isTerminalSymbol(gramm, id) ? gramm._T[id-0x03e8] : gramm._N[id]


"""
    isTerminalSymbol(gramm::Grammar, id::UInt16)::Bool

Returns the correspondence of a numeric symbol, a string.
"""
isTerminalSymbol(gramm::Grammar, id::UInt16)::Bool = id > 0x03e7


"""
    getNRules(gramm::Grammar)::UInt16

Returns the number of rules in the grammar, meaning all the consequent.
"""
function getNRules(gramm::Grammar)::UInt16
    nRules::UInt16 = 0x0
    for i=eachindex(gramm._P)
        nRules = nRules + getNRules(gramm._P[i])
    end
    return nRules
end


"""
    getNProductionRules(gramm::Grammar)::UInt16

Returns the number of production rules in the grammar.
"""
getNProductionRules(gramm::Grammar)::UInt16 = gramm._nProductionRules


"""
    getNConsequent(gramm::Grammar, id::UInt16)::UInt8

A interface for `getNConsequent(productionRule::ProductionRule)`.
"""
getNConsequent(gramm::Grammar, id::UInt16)::UInt8 = getNConsequent(getProductionRule(gramm, id))


"""
    getPosibleConsequentProductions(gramm::Grammar, antecedent::UInt16,
            productions::UInt16=0xffff)::Tuple{Array{UInt8}, UInt8}

A interface for `getPosibleConsequentProductions(productionRule::ProductionRule, productions)`.
"""
getPosibleConsequentProductions(gramm::Grammar, antecedent::UInt16,
            productions::UInt16=0xffff)::Tuple{Array{UInt8}, UInt8} = getPosibleConsequentProductions(getProductionRule(gramm, antecedent), productions)


"""
    getPosibleRecursiveProductions(gramm::Grammar, antecedent::UInt16,
            productions::UInt16=0xffff)::Tuple{Array{UInt8}, UInt8}

A interface for `getPosibleRecursiveProductions(productionRule::ProductionRule, productions)`.
"""
getPosibleRecursiveProductions(gramm::Grammar, antecedent::UInt16,
        productions::UInt16=0xffff)::Tuple{Array{UInt8}, UInt8} = getPosibleRecursiveProductions(getProductionRule(gramm, antecedent), productions)


"""
    getPosibleConsequentDepth(gramm::Grammar, antecedent::UInt16, depth::UInt8=0xff,
            productions::UInt16=0xffff)::Tuple{Array{UInt8}, UInt8}

A interface for `getPosibleConsequentDepth(productionRule::ProductionRule, depth, productions)`.
"""
getPosibleConsequentDepth(gramm::Grammar, antecedent::UInt16, depth::UInt8=0xff,
        productions::UInt16=0xffff)::Tuple{Array{UInt8}, UInt8} = getPosibleConsequentDepth(getProductionRule(gramm, antecedent), depth, productions)


"""
    getPosibleRecursiveDepth(gramm::Grammar, antecedent::UInt16, depth::UInt8=0xff,
            productions::UInt16=0xffff)::Tuple{Array{UInt8}, UInt8}

A interface for `getPosibleRecursiveDepth(productionRule::ProductionRule, depth, productions)`.
"""
getPosibleRecursiveDepth(gramm::Grammar, antecedent::UInt16, depth::UInt8=0xff,
        productions::UInt16=0xffff)::Tuple{Array{UInt8}, UInt8} = getPosibleRecursiveDepth(getProductionRule(gramm, antecedent), depth, productions)


"""
    getConsequent(gramm::Grammar, antecedent::UInt16, index::UInt8)::Consequent

A interface for `getConsequent(productionRule::ProductionRule, index)`.
"""
getConsequent(gramm::Grammar, antecedent::UInt16, index::UInt8)::Consequent = getConsequent(getProductionRule(gramm, antecedent), index)




"""
    getMaxSymbols(gramm::Grammar)

Returns the number of non terminal symbols of the rule that has more non terminal symbol.
"""
function getMaxSymbols(gramm::Grammar)
    max = 0
    for productionRule in gramm._P
        for consequent in productionRule._consequent
            current = 0
            for i in eachindex(consequent._symbols)
                if !isTerminalSymbol(gramm, consequent._symbols[i])
                    current += 1
                end
            end
            if current > max
                max = current
            end
        end
    end
    return max
end
