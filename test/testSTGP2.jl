using DataFrames
using CSV
using Random

using EvoLab
using EvoLab.GP.STGP

println("hola")
println("hola")
println("hola")

rng = Random.MersenneTwister(2)
rng = Random.MersenneTwister(421)
rng = Random.MersenneTwister(8543)

df = CSV.read("test/heart.csv")
nPatrones = size(df, 1)
df = df[Random.shuffle(rng, 1:nPatrones), :]

age = df[:, :age]
sex = Array{Bool}(df[:, :sex])
cpain = df[:, :cp]
trestbps = df[:, :trestbps]
chol = df[:, :chol]
fbs = Array{Bool}(df[:, :fbs])
restecg = df[:, :restecg]
thalach = df[:, :thalach]
exang = Array{Bool}(df[:, :exang])
oldpeak = df[:, :oldpeak]
slope = df[:, :slope]
ca = df[:, :ca]
thal = df[:, :thal]
clases = Array{Bool}(df[:, :target])


function CCR(genotype::STGPGenotype, gpExperimentInfo::STGPInfo, clases::Array{Bool})

    aciertos = 0
    fenotipo = getPhenotype(genotype)

    for i=1:nPatrones
        clase_estimada = evalPhenotype(fenotipo, gpExperimentInfo._varValues[i])
        if typeof(clase_estimada) <: Bool
            if clases[i] == clase_estimada
                aciertos += 1
            end
        end
    end

    return (aciertos/nPatrones)*100
end

function nNodes(canonicalgp::GPGenotype, gpInfo)
    length(canonicalgp._representation)
end


####################### Un solo fitness #########################

clearGenJ()
setIndividualType(STGPGenotype)
setRNG(rng)
setSTGPInfo(age, sex, cpain, trestbps, chol, fbs, restecg, thalach, exang, oldpeak,
            slope, ca, thal,
            nodesFile="src/utils/GeneticProgramming/StronglyTyped/exampleNodesSTGP2.json")
setStopCondition(maxIterations = 500)
setEvaluator([FitnessFunction(CCR, clases, weight=1)])
setGenerator(rampedHalfHalfGenerator, popSize = 100, generateOneByOne = false)
setExperimentSummary(batchSize=1)





clearGenJ()
setIndividualType(STGPGenotype)
setRNG(rng)
setSTGPInfo(age, sex, cpain, trestbps, chol, fbs, restecg, thalach, exang, oldpeak,
            slope, ca, thal,
            nodesFile="src/utils/GeneticProgramming/StronglyTyped/exampleNodesSTGP2.json")
setStopCondition(maxIterations = 100)
setEvaluator([FitnessFunction(CCR, clases, weight=1)])
setGenerator(rampedHalfHalfGenerator, popSize = 50, generateOneByOne = false)
setSelector(tournamentSelector, 5)
setCrossoverOperator(subtreeCross, probability = 0.9)
setMutationOperator(subtreeMutation, probability = 0.2)
setReplacementOperator(replaceAllPopulation, eliteSize=5)
setExperimentSummary(batchSize=1)





clearGenJ()
setIndividualType(STGPGenotype)
setRNG(rng)
setSTGPInfo(age, sex, cpain, trestbps, chol, fbs, restecg, thalach, exang, oldpeak,
            slope, ca, thal,
            nodesFile="src/utils/GeneticProgramming/StronglyTyped/exampleNodesSTGP2.json")
setStopCondition(maxIterations = 300)
setEvaluator([FitnessFunction(CCR, clases, weight=1)])
setGenerator(rampedHalfHalfGenerator, popSize = 100, generateOneByOne = false)
setSelector(tournamentSelector, 2, nSelected=10)
setCrossoverOperator(subtreeCross, probability = 0.8)
setMutationOperator(pointMutation, 0.3, probability = 0.2)
setReplacementOperator(replaceWorstIndividuals, eliteSize=3, needsComparison=true)
setExperimentSummary(batchSize=1)



####################### Multifitness #########################



clearGenJ()
setAlgorithm(SPEA, 10)
setIndividualType(STGPGenotype)
setRNG(rng)
setSTGPInfo(age, sex, cpain, trestbps, chol, fbs, restecg, thalach, exang, oldpeak,
            slope, ca, thal,
            nodesFile="src/utils/GeneticProgramming/StronglyTyped/exampleNodesSTGP2.json")
setStopCondition(maxIterations = 500)
setEvaluator([FitnessFunction(CCR, clases, weight=1), FitnessFunction(nNodes, weight=-0.2)],
             globalFitnessFunction=FitnessFunction(pareto), compareFunctionArgs="global")
setGenerator(rampedHalfHalfGenerator, popSize = 100, generateOneByOne = false)
setExperimentSummary(batchSize=1)



clearGenJ()
setIndividualType(STGPGenotype)
setAlgorithm(SPEA, 10)
setRNG(rng)
setSTGPInfo(age, sex, cpain, trestbps, chol, fbs, restecg, thalach, exang, oldpeak,
            slope, ca, thal,
            nodesFile="src/utils/GeneticProgramming/StronglyTyped/exampleNodesSTGP2.json")
setStopCondition(maxIterations = 100)
setEvaluator([FitnessFunction(CCR, clases, weight=1), FitnessFunction(nNodes, weight=-0.2)],
             globalFitnessFunction=FitnessFunction(pareto), compareFunctionArgs="global")
setGenerator(rampedHalfHalfGenerator, popSize = 50, generateOneByOne = false)
setSelector(tournamentSelector, 5)
setCrossoverOperator(subtreeCross, probability = 0.9)
setMutationOperator(subtreeMutation, probability = 0.2)
setReplacementOperator(replaceAllPopulation, eliteSize=5)
setExperimentSummary(batchSize=1)



clearGenJ()
setIndividualType(STGPGenotype)
setAlgorithm(SPEA, 10)
setRNG(rng)
setSTGPInfo(age, sex, cpain, trestbps, chol, fbs, restecg, thalach, exang, oldpeak,
            slope, ca, thal,
            nodesFile="src/utils/GeneticProgramming/StronglyTyped/exampleNodesSTGP2.json")
setStopCondition(maxIterations = 300)
setEvaluator([FitnessFunction(CCR, clases, weight=1), FitnessFunction(nNodes, weight=-0.2)],
             globalFitnessFunction=FitnessFunction(pareto), compareFunctionArgs="global")
setGenerator(rampedHalfHalfGenerator, popSize = 100, generateOneByOne = false)
setSelector(tournamentSelector, 2, nSelected=10)
setCrossoverOperator(subtreeCross, probability = 0.8)
setMutationOperator(pointMutation, 0.3, probability = 0.2)
setReplacementOperator(replaceWorstIndividuals, eliteSize=3, needsComparison=true)
setExperimentSummary(batchSize=1)



val, t, bytes, gctime, memallocs = @timed runExperiment(verbose = false)
println("tiempo: ", t)
println("memoria (MB): ", bytes/1000000)

using Plots

myfont = font(13, "cursive")
mylittlefont = font(8, "cursive")
iters = 300
bestInds1 = GenJ._experimentInfo._experimentSummary._bestFitnessValues[1, :]

display(plot(collect(1:iters), bestInds1, titlefont=myfont, tickfont=myfont,
             legendfont=mylittlefont, yguide="Valores de fitness", xguide="Generaciones",
             guidefont=myfont, label="", lw=1.5))


bestInds2 = GenJ._experimentInfo._experimentSummary._bestFitnessValues[2, :]

display(plot!(collect(1:iters), bestInds2, titlefont=myfont, tickfont=myfont,
          legendfont=mylittlefont, yguide="Valores de fitness", xguide="Generaciones",
          guidefont=myfont, label="", lw=1.5))

bestIndsG = GenJ._experimentInfo._experimentSummary._bestFitnessValues[end, :]

display(plot!(collect(1:iters), bestIndsG, titlefont=myfont, tickfont=myfont,
        legendfont=mylittlefont, yguide="Valores de fitness", xguide="Generaciones",
        guidefont=myfont, label="", lw=1.5))

means1 = GenJ._experimentInfo._experimentSummary._meanFitness[1, :]

display(plot!(collect(1:iters), means1, titlefont=myfont, tickfont=myfont,
             legendfont=mylittlefont, yguide="Valores de fitness", xguide="Generaciones",
             guidefont=myfont, label="", lw=1.5))

 means2 = GenJ._experimentInfo._experimentSummary._meanFitness[2, :]

 display(plot!(collect(1:iters), means2, titlefont=myfont, tickfont=myfont,
              legendfont=mylittlefont, yguide="Valores de fitness", xguide="Generaciones",
              guidefont=myfont, label="", lw=1.5))

meansG = GenJ._experimentInfo._experimentSummary._meanFitness[end, :]

display(plot!(collect(1:iters), meansG, titlefont=myfont, tickfont=myfont,
           legendfont=mylittlefont, yguide="Valores de fitness", xguide="Generaciones",
           guidefont=myfont, label="", lw=1.5))
