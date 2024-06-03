using Distributions
using Random
using DeferredAcceptance

function simulate(numTimes, schools, students, capacities)
    assnMat = Array{Int}(undef, numTimes, size(schools)[1])
    for i in 1:numTimes
        schools_tiebroken = STB(schools) # basically the lotto numbers
        students_tiebroken = STB(students) # just to break the 999 rankings
        assn, _ = DA(students_tiebroken, schools_tiebroken, capacities; verbose=true)
        @assert isstable(students, schools, capacities, assn)
        assnMat[i,:] = assn
    end
    return(assnMat)
end

function choices(numStudents, numSchools, totalSchools, numRankings, maxRank=999)
    students = Array{Int}(undef, totalSchools, numStudents)
    for i = 1:numStudents
        student = studentRanking(numSchools, totalSchools, maxRank)
        students[:,i] = student
    end

    schools = Array{Int}(undef, numStudents, totalSchools)
    for i = 1:totalSchools
        priority = priorityRanking(students[i,:], numRankings, maxRank)
        schools[:,i] = priority
    end

    return(students, schools)
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

numStudents=15
numSchools=3
totalSchools=5
numRankings=8
students, schools = choices(numStudents, numSchools, totalSchools, numRankings)
assnMat = simulate(15, schools, students, rand((2,4),totalSchools))
