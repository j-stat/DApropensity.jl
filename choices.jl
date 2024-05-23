using Distributions
using Random
using DeferredAcceptance

function simulate(numTimes, schools, students, capacities)
    schools_tiebroken = singletiebreaking(schools)
    assn, rank = deferredacceptance(students, schools_tiebroken, capacities)
    println(assn)
end

function choices(numStudents, numSchools, totalSchools, numRankings, maxRank=999)
    students = Array{Int}(undef, numStudents, totalSchools)
    for i = 1:numStudents
        student = studentRanking(numSchools, totalSchools, maxRank)
        students[i,:] = student
    end

    schools = Array{Int}(undef, totalSchools, numStudents)
    for i = 1:totalSchools
        priority = priorityRanking(students[:,i], numRankings, maxRank)
        schools[i,:] = priority
    end
end

# student chooses m schools out of possible M
# no school can have the same ranking, i.e. 2 schools cannot both have ranking 1
# non chosen schools get ranked at bottom (i.e. maxRank)
function studentRanking(numSchools, totalSchools, maxRank)
    shuf = shuffle(1:totalSchools) # to be replaced later with actual distribution
    replace(x -> x .> numSchools ? maxRank : x, shuf)
end

# school gives student 1 of its k priority rankings 
# updated so students get ranking at each school to which they apply
# only ranks students that have chosen the school
# can be tied
function priorityRanking(ranks, numRankings, maxRank)
    replace(x -> x .!= maxRank ? rand(DiscreteUniform(1, numRankings)) : x, ranks)
end

choices(10, 3, 5, 8)