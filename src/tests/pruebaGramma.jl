
include("../base.jl")

randomInt()=rand()

mutable struct Consequent
    _symbols::Array{String}
    _depth::Number
    _recursive::Bool
    Consequent(symbols::Array{String}) = new(symbols, -Inf, false)
    Consequent(symbols::Array{String}, depth::Number) = new(symbols, depth, false)
end

mutable struct ProductionRule
    _antecedent::String
    _consequent::Array{Consequent}
    _depth::Number

    ProductionRule(antecedent::String, consequent::Array{Consequent}) = new(antecedent, consequent, -Inf)
end

struct Grammar
    _N::Array{String}
    _T::Array{String}
    _P::Array{ProductionRule}
    _S::String
end # struct


getInitialSymbol(gramm::Grammar) = Grammar._S

function hasDepth(productionRule::ProductionRule)
    productionRule._depth != -Inf
end

function getDepth(productionRule::ProductionRule)
    productionRule._depth
end

function getNRules(productionRule::ProductionRule)
    length(productionRule._consequent)
end

function getRule(productionRule::ProductionRule, index::UInt)
    index = index % length(productionRule._consequent) + 1
    productionRule._consequent[index]
end


function getProductionRule(productionRules::Array{ProductionRule}, symbol::String)
    for i=1:length(productionRules)
        if symbol == productionRules[i]._antecedent
            return productionRules[i]
        end
    end
end

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


function isTerminalSymbol(gramm::Grammar, symbol::String)
    check = false
    for i=1:length(gramm._T)
        if gramm._T[i] == symbol
            check = true
            break
        end
    end
    return check
end

function getNRules(gramm::Grammar)
    nRules = 0
    for i=1:length(gramm._P)
        productionRule = gramm._P[i]
        nRules = nRules + getNRules(productionRule)
    end
    return nRules
end

function getNProductionRules(gramm::Grammar)
    return length(gramm._P)
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










"""
function getPhenotype(GEInd::GEIndividual, Grammar)
    stack = Array{Node}(undef,0)
    pushfirst!(stack, getInitialSymbol(Grammar))


end

"""

println("hola")


N=["expr","op", "pre-op", "var"]
T=["x", "sin", "cos", "tan", "log", "+", "-", "/", "*", "(", ")"]


R=["<expr> -> <expr> <op> <expr>
         | (<expr> <op> <expr>)
         | <pre-op> ( <expr> )
         | <var>",

   "<op> -> +
        | -
        | /
        | *",

    "<pre-op> -> sin
                | cos
                | tan
                | log",

    "<var> -> x"
]

S="expr"


 a=parseNo(N, T, R, S)
