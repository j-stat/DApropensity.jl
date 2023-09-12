using Distributions
using Random
using DeferredAcceptance

function choices(numStudents, numSchools, totalSchools, numRankings)
    for i = 1:numStudents
        schoolRank = schools(numSchools, totalSchools)
        println(schoolRank) # for debugging
        priorityRank = priority(numRankings)
        println(priorityRank) # for debugging
    end
    # todo: configure output to go into DA algorithm
end

# student chooses m schools out of possible M
function schools(numSchools, totalSchools)
    rand(DiscreteUniform(1, totalSchools), numSchools)
end

# school gives student 1 of its k priority rankings
function priority(numRankings)
    rand(DiscreteUniform(1, numRankings))
end

function lottery(numStudents, numSims)
    randperm(numStudents)
    # todo: configure output to go into DA algorithm
end

choices(10, 3, 5, 8)