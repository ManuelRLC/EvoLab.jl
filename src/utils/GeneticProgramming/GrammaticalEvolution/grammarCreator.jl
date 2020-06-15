

function allConsequentAreSet(productionRule::ProductionRule)
    check = true
    for i=1:length(productionRule._consequent)
        if productionRule._consequent[i]._depth == -Inf
            check = false
            break
        end
    end
    return check
end





function setFourthDepth!(gramm::Grammar)

    function isRecursive(symbol::UInt16)

        rule = getProductionRule(gramm, symbol)
        recursive = false
        for i=1:length(rule._consequent)
            if rule._consequent[i]._recursive
                recursive = true
            else
                recursiveInternal = false
                if rule._consequent[i]._depth != 0
                    for j=1:length(rule._consequent[i]._symbols)
                        if !isTerminalSymbol(gramm, rule._consequent[i]._symbols[j])
                            if isRecursive(rule._consequent[i]._symbols[j])
                                recursive = true
                                recursiveInternal = true
                            end
                        end
                    end
                    rule._consequent[i]._recursive = recursiveInternal
                end
            end
        end
        return recursive
    end

    for i=1:length(gramm._P)
        productionRule = gramm._P[i]
        isRecursive(productionRule._antecedent)
    end

end

"""
    Profundidad para aquellos consecuentes que sean Inf, en este punto ya deberia conocer cual es
    su profundidad.
"""

function setThirdDepth!(gramm::Grammar)


    for i=1:length(gramm._P)
        productionRule = gramm._P[i]
        for j=1:length(productionRule._consequent)
            antecedent = productionRule._antecedent
            consequent = productionRule._consequent[j]
            depth = 0;
            count = 0;

            if consequent._depth == 32000
                max = 0
                sum = 0
                for g=1:length(consequent._symbols)
                    symbol = consequent._symbols[g]
                    if !isTerminalSymbol(gramm, symbol)
                        current = getDepth(gramm, symbol)
                        sum = sum + current
                        if current > max
                            max = current
                        end
                    end
                end
                consequent._minProductions = sum
                consequent._depth = max
            end
        end
    end

end

"""
    Esta profundidad es para aquellos consecuentes que sean -Inf (que no esten seteados),
    y para setear los antecedentes que tenga como consecuente Inf y algun valor establecido
    de profundidad en otros, cogiendo el minimo de estos otros como profundidad.
"""

function setSecondDepth!(gramm::Grammar)

    count = length(gramm._P)
    nIter = 0
    nMaxIter = getNRules(gramm) + getNProductionRules(gramm)

    while (count != 0 && nIter < nMaxIter)
        count = 0
        nIter = nIter + 1
        for i=1:length(gramm._P)
            productionRule = gramm._P[i]
            nInf = 0
            if !allConsequentAreSet(productionRule) || !hasDepth(productionRule)
                nConsequentSet = 0
                min = 32000

                for j=1:length(productionRule._consequent)
                    antecedent = productionRule._antecedent
                    consequent = productionRule._consequent[j]
                    if consequent._depth == 32000
                        nInf = nInf + 1
                        nConsequentSet = nConsequentSet + 1
                    elseif consequent._depth == -32000
                        max = -32000
                        sum = 0
                        for g=1:length(consequent._symbols)
                            symbol = consequent._symbols[g]
                            if !isTerminalSymbol(gramm, symbol)

                                current = getDepth(gramm, symbol)
                                sum = sum + current
                                if current == -32000
                                    max = -32000
                                    break
                                end
                                if current > max
                                    max = current
                                end
                            end
                        end
                        if sum != -32000
                            consequent._minProductions = sum
                            consequent._depth = max
                        end
                    else
                        nConsequentSet = nConsequentSet + 1
                        current = consequent._depth
                        if current < min
                            min = current
                        end
                    end

                end
                if nInf == length(productionRule._consequent)
                    error("The production rule of <$(productionRule._antecedent)> doesn't lead to any terminal or it appears in all of its consequents")
                end
                if nConsequentSet == length(productionRule._consequent)
                    productionRule._depth = min + 1
                else
                    count = count + 1
                end
            end
        end
    end
    if nIter == nMaxIter
        error("The grammar has a loop. For example: <ex> -> <var> ; <var> -> <ex>")
    end
end

""" Setea la primera profundidad es decir, aquellos consecuentes que sean un no terminal se setean a 0 profundidad,
    y las reglas de produccion que los contienen a 1 de profundidad. Por otro lado, aquellas reglas con recursividad
    directa se setean como recursivas e Inf.
"""
function setFirstDepth!(gramm::Grammar)


    for i=1:length(gramm._P)
        productionRule = gramm._P[i]
        for j=1:length(productionRule._consequent)
            antecedent = productionRule._antecedent
            consequent = productionRule._consequent[j]
            depth = 0;
            count = 0;
            for g=1:length(consequent._symbols)
                symbol = consequent._symbols[g]

                if !isTerminalSymbol(gramm, symbol)
                    if symbol == antecedent
                        consequent._depth = 32000
                        consequent._recursive = true
                        break
                    end
                else
                    count = count + 1
                end
            end
            if count == length(consequent._symbols)
                consequent._depth = 0
                consequent._minProductions = 0
                productionRule._depth = 1
            end
        end
    end
end


function setDepth!(gramm::Grammar)
    setFirstDepth!(gramm)
    setSecondDepth!(gramm)
    setThirdDepth!(gramm)
    setFourthDepth!(gramm)
end




function reorderNonTerminals!(N::Array{String}, productionRules::Array{ProductionRule})
    len = length(N)

    newN = similar(Array{String}, len)
    reference = similar(Array{UInt16}, len)

    for i in eachindex(productionRules)
        reference[i] = productionRules[i]._antecedent
    end
    aux = [(reference[i], N[i]) for i=1:len]
    aux = sort(aux)

    for i in eachindex(productionRules)
        productionRules[i]._antecedent = i
        N[i] = aux[i][2]
    end


    for i in eachindex(productionRules)
        productionRule = productionRules[i]
        for j in eachindex(productionRule._consequent)
            antecedent = productionRule._antecedent
            consequent = productionRule._consequent[j]
            depth = 0;
            count = 0;
            for g in eachindex(consequent._symbols)
                if consequent._symbols[g] < 1000
                    consequent._symbols[g] = findfirst(x->consequent._symbols[g]==x, reference)
                end
            end
        end
    end


end


function readSymbol(str::String)
    nullChar(element) = findnext(x->x==element, [' ','\n','\r','\t'], 1) != nothing
    count = 0
    len = length(str)
    i = 2
    symbol = ""
    while (str[i]!='>')
        if nullChar(str[i])
            error("There shouldn't be neither whitespaces nor line breaks inside a <symbol>")
        else
            symbol=symbol*str[i]
            i=i+1
        end
        if i > len
            error("While reading a symbol, the string ends prematurely")
        end
    end
    if i == 1
        error("Symbol must have, at least, one character")
    end

    return symbol, i
end





function createGrammar(N::Array{String}, T::Array{String}, P::Array{String}, S::String)
    if findnext(x->x==S,N,1) == nothing
        error("The initial symbol S ($S) must be in the non-terminal set, N")
    end

    nullChar(element) = findnext(x->x==element, [' ','\n','\r','\t'], 1) != nothing
    function findNextNotNullChar(str, i)
        index = findnext(!nullChar, str, i)
        index == nothing ? nothing : collect(index)[1]
    end
    function findNextNull(str, i)
        index = findnext(nullChar, str, i)
        index == nothing ? nothing : collect(index)[1]
    end

    productionRules = Array{ProductionRule}(undef, 0)


    for productionRule in P
        consequents = Array{Consequent}(undef,0)
        symbol = ""
        antecedent = false

        len = length(productionRule)
        antecedentSymbol = ""
        symbols = Array{UInt16}(undef, 0)

        i = 1
        while (i<=len)
            if !nullChar(productionRule[i])
                # If the antecedent is not found yet, the first letter must be '<'
                if !antecedent
                    if productionRule[i] != '<'
                        error("The first character of the production rule must be '<' which represents the begining of the antecedent symbol")
                    else
                        antecedentSymbol, sum = readSymbol(productionRule[i:end])
                        symbolIndex = findnext(x->x==antecedentSymbol, N, 1)

                        if symbolIndex == nothing
                            error("Nonterminal symbol ($symbol) is in production rules, but it isn't in Non-terminal set, N")
                        end

                        antecedentSymbol = symbolIndex

                        i = i + sum
                        i = findNextNotNullChar(productionRule, i)
                        if productionRule[i] != '-'
                            error("The character expected after the antecedent symbol is '-' ")
                        end
                        if productionRule[i+1] != '>'
                            error("The character expected after the antecedent symbol and '-' is '>'")
                        end
                        i = i+2
                        antecedent = true
                    end

                # Inside the consequent of the rule
                else
                    if productionRule[i] == '<'
                        symbol, sum = readSymbol(productionRule[i:end])
                        symbolIndex = findnext(x->x==symbol, N, 1)
                        if symbolIndex == nothing
                            error("Non-terminal symbol ($symbol) is in production rules, but it isn't in Non-terminal set, N")
                        end

                        push!(symbols, symbolIndex)
                        i = i + sum - 1
                        if findnext(x->!nullChar(x), productionRule, i+1) == nothing
                            push!(consequents, Consequent(symbols))
                            break
                        end
                    elseif productionRule[i] == '|'
                        if length(symbols) == 0
                            error("A '|' found without any symbol before")
                        end

                        push!(consequents, Consequent(symbols))
                        symbols = Array{UInt16}(undef, 0)
                        if productionRule[i:end] == "| <var> "
                            activate = true
                        end
                    else

                        next = findnext(x->nullChar(x) || x=='<', productionRule, i)
                        if next == nothing
                            symbol = productionRule[i:end]
                            symbolIndex = findnext(x->x==symbol, T, 1)
                            if symbolIndex == nothing
                                error("Terminal symbol ($symbol) is in production rules, but it isn't in Terminal set, T")
                            end
                            push!(symbols, symbolIndex+1000)
                            push!(consequents, Consequent(symbols))
                            break
                        else
                            next = collect(next)[1]
                            symbol = productionRule[i:next-1]
                            if symbol == "SP"
                                if findfirst(" ", T) == nothing
                                    push!(T, " ")
                                end
                                symbol = " "
                            end
                            symbolIndex = findnext(x->x==symbol, T, 1)
                            if symbolIndex == nothing
                                error("Terminal symbol ($symbol) is in production rules, but it isn't in Terminal set, T")
                            end
                            push!(symbols, symbolIndex+1000)
                            i = next-1
                        end
                    end
                end
            end
            i = i+1
        end
        if antecedent == -1 || antecedent == 0
            error("The antecendent must be followed by '->' and there should be an antecedent")
        end

        push!(productionRules, ProductionRule(antecedentSymbol, consequents))
    end
    for i in eachindex(N)
        antecedents = [x._antecedent for x in productionRules]
        if findnext(x->x==i, antecedents, 1) == nothing
            error("Non-terminal symbol ($(N[i])) isn't an antecedent of any production rule")
        end
    end

    reorderNonTerminals!(N, productionRules)
    gramm = Grammar(N, T, productionRules, S)

    setDepth!(gramm)

    return gramm
end
