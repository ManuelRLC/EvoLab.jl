
using DecisionTree, DataFrames, CSV
using ScikitLearn.Skcore: score
using EvoLab
using EvoLab.GA.IntegerGA
using Random
using Plots

a = CSV.read("test/experiments/wine.csv")
df = DataFrame(CSV.File("test/experiments/wine.csv"))
rng = Random.MersenneTwister(10)

function partitionTrainTest(data, rng, at = 0.7)
    n = nrow(data)
    idx = shuffle(rng, 1:n)
    train_idx = view(idx, 1:floor(Int, at*n))
    test_idx = view(idx, (floor(Int, at*n)+1):n)
    data[train_idx,:], data[test_idx,:]
end


train, test = partitionTrainTest(df, rng)

x_train = convert(Matrix, select(train, Not(:class)))
y_train = string.(train[:, :class])
x_test = convert(Matrix, select(test, Not(:class)))
y_test = string.(test[:, :class])





function generateIndividual(rng)

    ind = Array{Int8}(undef, 4)
    # Max depth
    ind[1] = rand(rng, [-1,1,2,3,4,5,6,7,8,9,10])
    # MinSamplesSplit
    ind[2] = rand(rng, [2,3,4,5,6,7,8,9,10])
    # MinSamplesLeaf
    ind[3] = rand(rng, [1,2,3,4,5,6,7,8,9,10])
    # n_subfeatures
    ind[4] = rand(rng, [1,2,3,4,5,6,7,8,9,10,11,12,13])
    return IntegerGenotype(ind)
end

function mutateTree(genotype, rng)

    rep = genotype._representation
    copyRep = copy(rep)

    if rand(rng) < 0.2
        index = rand(rng, [1,2,3,4,5,6])
        if index == 1
            copyRep[1] = rand(rng, [0,1,2,3,4,5,6,7,8,9,10])
        elseif index == 2
            copyRep[2] = rand(rng, [2,3,4,5,6,7,8,9,10])
        elseif index == 3
            copyRep[3] = rand(rng, [1,2,3,4,5,6,7,8,9,10])
        elseif index == 4
            copyRep[4] = rand(rng, [1,2,3,4,5,6,7,8,9,10,11,12,13])
        end
    end
    return IntegerGenotype(copyRep)
end



function learnDecisionTree(genot::IntegerGenotype{Int8}, rng,
                           x_train, y_train, x_test, y_test)

    rep = genot._representation

    model = DecisionTreeClassifier(max_depth=rep[1], min_samples_split=rep[2], min_samples_leaf=rep[3],
                                    n_subfeatures = rep[4], rng = rng)
    fit!(model, x_train, y_train)

    accuracy = score(model, x_test, y_test)
    #accuracy = accuracy_score(y_test, y_predict)
    return accuracy
end



clearGenJ()

setIndividualType(IntegerGenotype{Int8})
setRNG(rng)
setStopCondition(maxIterations = 500)
setEvaluator(FitnessFunction(learnDecisionTree, weight=1, rng, x_train, y_train, x_test, y_test))
setGenerator(generateIndividual, popSize = 100)
setSelector(tournamentSelector, 3, samplingWithRep = true, nSelected = 1.0)
setCrossoverOperator(singlePointCross, nChildren = 2)
setMutationOperator(mutateTree)
setReplacementOperator(replaceAllPopulation, eliteSize = 1)
setExperimentSummary(printFitness=false, printDuringExperiment=true)
setExperimentSummary(printBestFitness=true, batchSize = 1)


@time runExperiment(verbose=false)

x = GenJ._experimentInfo._experimentSummary._meanFitness
y = collect(1:500)

plot(y[1:100],x[1,1:100])

x2 = GenJ._experimentInfo._experimentSummary._bestFitnessValues
plot(y[1:200],x2[1,1:200])

println("Best individual is: $(GenJ._experimentInfo._experimentSummary._bestIndividuals[end])")
