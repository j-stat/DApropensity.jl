using Distributions
using Random
using DeferredAcceptance

function simulate(numTimes, schools)
    schools_tiebroken = singletiebreaking(schools)
    assn, rank = deferredacceptance(students, schools_tiebroken, capacities)
    println(assn)
end

function choices(numStudents, numSchools, totalSchools, numRankings)
    students = Array{Int}(undef, numStudents, totalSchools)
    #schools = Array{Int}(undef, totalSchools, numStudents)
    for i = 1:numStudents
        schoolRank = schools(numSchools, totalSchools)
        students[i,:] = schoolRank
        priorityRank = priority(numRankings, numSchools)
        #schools[i,:] .= prioritRank
        println(priorityRank) # for debugging
    end
    # todo: configure output to go into DA algorithm
    println(students)
end

# student chooses m schools out of possible M
# no school can have the same ranking, i.e. 2 schools cannot both have ranking 1
# non chosen schools get ranked at bottom (i.e. 9999)
function schools(numSchools, totalSchools)
    shuf = shuffle(1:totalSchools) # to be replaced later with actual distribution
    replace(x -> x .> numSchools ? 999 : x, shuf)
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