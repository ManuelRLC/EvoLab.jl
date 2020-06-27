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


S = "expr"

clearGenJ()
setRandomSeed(5)

setGEInfo(N, T, R, S, ["x", "y"], x, y, maxProductions = 50, maxDepth = 8)

setIndividualType(GEGenotype)
#setAlgorithm(EvoLab.basicExperimentDeep)
setAlgorithm(EvoLab.basicExperimentDeep)
setStopCondition(maxIterations=50)
setEvaluator([FitnessFunction(compareFunctions, objs, weight=-1)])
setGenerator(rampedHalfHalfGenerator, popSize = 50, generateOneByOne = false)
setSelector(tournamentSelector, 4)
setCrossoverOperator(proteinCross, probability = 0.9)
setNullMutation()
setMutationOperator(proteinMutation, uniformMutation, 0, 255, 10, probability = 0.5)
setReplacementOperator(replaceAllPopulation, eliteSize=5)
setExperimentSummary()

@time runExperiment(verbose = false)
