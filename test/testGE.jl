
using EvoLab
using EvoLab.GP.GE
using EvoLab.GA.IntegerGA

f(x, y) = (y / 5.5) + x^2



println("hola")
println("hola")

x = collect(-5:0.5:5)
y = collect(0:0.5:10)


nvalues = length(x)
objs = Array{Number}(undef, nvalues)
for i = 1:nvalues
    objs[i] = f(x[i], y[i])
end

"""
N=["expr","op", "pre-op", "var"]
T=["x", "sin", "cos", "tan", "log", "+", "-", "/", "*", "(", ")"]

# <expr> <op> <expr>

R=["<expr> -> (<expr> <op> <expr>)
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
"""

N = ["expr", "op", "var", "cons", "int", "digit"]
T = [
    "x",
    "y",
    "+",
    "-",
    "/",
    "*",
    "(",
    ")",
    "0",
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    ".",

]

#"\"\"\"\nInterpolate using `\\\$`\n\"\"\"\n"
# <expr> <op> <expr>

R = [
    "<expr> -> (<expr> <op> <expr>)
             | <var>
             | <cons>",
    "<op> -> +
           | -
           | /
           | *",
    "<var> -> x
            | y",
    "<cons> -> <int> | <int>.<int>",
    "<int> -> <int><digit> | <digit>",
    "<digit> -> 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9",
]

R2 = [
    "<expr> -> (<expr> <op> <expr>)
             | <var>",
    "<op> -> +
           | -
           | /
           | *",
    "<var> -> x
            | y"
]


S = "expr"
println("Hola")
println("Hola")

clearGenJ()
setRandomSeed(5)

myrandom() = rand(GenJ._experimentInfo._rng, collect(0:9))
setGEInfo(N, T, R, S, ["x", "y"], x, y, maxProductions = 50, maxDepth = 8)

setIndividualType(GEGenotype)
#setAlgorithm(EvoLab.basicExperimentDeep)
setAlgorithm(basicExperiment)
setStopCondition(maxIterations=2)
setEvaluator([FitnessFunction(compareFunctions, objs, weight=-1)])
setGenerator(rampedHalfHalfGenerator, popSize = 50, generateOneByOne = false)
setSelector(tournamentSelector, 4)
setCrossoverOperator(proteinCross, probability = 0.9)
setNullMutation()
setMutationOperator(
    proteinMutation,
    uniformMutation,
    0,
    255,
    10,
    probability = 0.5,
)
setReplacementOperator(replaceAllPopulation, eliteSize=5)

@time runGenJ(verbose = false)
#genj = GeneticJulia.GenJ

#genPopulation!(GenJ)
#evaluate!(GenJ, GenJ._population)

"""

Ind1 = fullGenerator(GenJ._experimentInfo._GPExperimentInfo, GenJ._experimentInfo._rng)
Ind2 = fullGenerator(GenJ._experimentInfo._GPExperimentInfo, GenJ._experimentInfo._rng)

#children = onePointCrossDepth(Ind1, Ind2, GenJ._experimentInfo._GPExperimentInfo, GenJ._experimentInfo._rng)
#Ind2 = generateTree(GenJ._experimentInfo._GPExperimentInfo._grammar, Ind1._ind._representation)
#Ind2 = growGenerator(GenJ._experimentInfo._GPExperimentInfo, GenJ._experimentInfo._rng, Ind1._ind._representation)
println("Arbol1->(join(getPhenotype(Ind1._tree)))")
#Ind2 = fullGeneratorProductions(GenJ._experimentInfo._GPExperimentInfo, GenJ._experimentInfo._rng)
println("Arbol2->(getPhenotype(Ind2))")



#println(compareFunctions(Ind1, GenJ._experimentInfo._GPExperimentInfo, objs, x, y))
#println(compareFunctions(Ind2, GenJ._experimentInfo._GPExperimentInfo, objs, x, y))


Indcopy = copyGenotype(Ind1)


println(getPhenotype(GenJ._experimentInfo._GPExperimentInfo._grammar, Ind1))
println(getPhenotype(GenJ._experimentInfo._GPExperimentInfo._grammar, Ind2))
#println(getPhenotype(GenJ._experimentInfo._GPExperimentInfo._grammar, children[1]))
#println(getPhenotype(GenJ._experimentInfo._GPExperimentInfo._grammar, children[2]))

"""
#println("Parent1: lenInd = $(length(Ind1._ind._representation))  -> selections = $(length(Ind1._selections)) -> productions = $(Ind1._productions)")
#println("Parent2: lenInd = $(length(Ind2._ind._representation))  -> selections = $(length(Ind2._selections)) -> productions = $(Ind2._productions)")


#children = proteinCross(Ind1, Ind2, GenJ._experimentInfo._GPExperimentInfo, GenJ._experimentInfo._rng, kPointCross, 2)

#println("Child1 lenInd = $(length(children[1]._ind._representation))  -> selections = $(length(children[1]._selections)) -> productions = $(children[1]._productions)")
#println("Child2 lenInd = $(length(children[2]._ind._representation))  -> selections = $(length(children[2]._selections)) -> productions = $(children[2]._productions)")

"""
result = getPhenotype(children[1]._tree)
result2 = getPhenotype(children[2]._tree)
println(join(result))

printTree(Ind1._tree)

println()
println()
printTree(Ind2._tree)

result = getPhenotype(Ind1._tree)
result2 = getPhenotype(Ind2._tree, GenJ._experimentInfo._GPExperimentInfo)

child1 = getPhenotype(children[1]._tree, GenJ._experimentInfo._GPExperimentInfo)
child2 = getPhenotype(children[2]._tree, GenJ._experimentInfo._GPExperimentInfo)

println("Padre1: result")
println("Padre2: result2")
println("Hijo1: child1")
println("Hijo2: child2")
"""

"""utils
println(compareFunctions(Ind1, GenJ._experimentInfo._GPExperimentInfo, objs, x, y))

println(compareFunctions(Ind2, GenJ._experimentInfo._GPExperimentInfo, objs, x, y))
println(compareFunctions(children[1], GenJ._experimentInfo._GPExperimentInfo, objs, x, y))
println(compareFunctions(children[2], GenJ._experimentInfo._GPExperimentInfo, objs, x, y))
"""

#println(evaluate(Ind1, GenJ._experimentInfo._GPExperimentInfo, Dict("x" => 5)))
"""

x=5

println(auxstack)
println(selection)
println(result)

println()

println(auxstack2)
println(selection2)
println(result2)

"""

#println(Meta.parse(result))
#println(Meta.parse(result2))
