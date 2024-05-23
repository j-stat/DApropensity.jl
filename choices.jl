using Distributions
using Random
using DeferredAcceptance

function simulate(numTimes, schools)
    schools_tiebroken = singletiebreaking(schools)
end

function choices(numStudents, numSchools, totalSchools, numRankings)
    for i = 1:numStudents
        schoolRank = schools(numSchools, totalSchools)
        println(schoolRank) # for debugging
        priorityRank = priority(numRankings, numSchools)
        println(priorityRank) # for debugging
    end
    # todo: configure output to go into DA algorithm
end

# student chooses m schools out of possible M
function schools(numSchools, totalSchools)
    rand(DiscreteUniform(1, totalSchools), numSchools)
end

# school gives student 1 of its k priority rankings 
# updated so students get ranking at each school to which they apply
function priority(numRankings, m)
    rand(DiscreteUniform(1, numRankings), m)
end

function lottery(numStudents, numSims)
    randperm(numStudents)
    # todo: configure output to go into DA algorithm
end

choices(10, 3, 5, 8)