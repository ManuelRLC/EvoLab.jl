function miexperimento(prob::Number; genj::GenJulia = GenJ)
    # Generates a population

    genj._population = genPopulation(genj._generator, genj._experimentInfo)
    evaluate!(genj._evaluator, genj._experimentInfo, genj._population, genj._stopCondition)

    while !reached(genj._stopCondition)
        selectedParents = selectParents(genj._selector, genj._population, genj._crossoverOp._nParents, genj._evaluator, genj._experimentInfo._rng)


        offspring = genj._mutationOp._probability > 0.0 ? mutate(genj._mutationOp, selectedParents, genj._experimentInfo) : selectedParents

        evaluate!(genj._evaluator, genj._experimentInfo, offspring, genj._stopCondition)

        random = rand(genj._experimentInfo._rng)
        if random < prob
            genj._population = replacePopulation(genj._replacementOp, genj._population, offspring, genj._evaluator, genj._experimentInfo._rng)
        end

        notifyIteration(genj._stopCondition)
    end
end
