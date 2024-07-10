module DAPropensity

using Distributions
using Random
using DeferredAcceptance
using DataFrames

function simulate(numTimes, students, schools, capacities)
    assnMat = Array{Int}(undef, numTimes, size(schools)[1])
    for i in 1:numTimes
        schools_tiebroken = singletiebreaking(schools)
        students_tiebroken = singletiebreaking(students)
        assn, _ = deferredacceptance(students_tiebroken, schools_tiebroken, capacities; verbose=true)
        #schools_tiebroken = STB(schools) # basically the lotto numbers
        #students_tiebroken = STB(students) # just to break the 999 rankings
        #assn, _ = DA(students_tiebroken, schools_tiebroken, capacities; verbose=true)
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

# DA Propensity score calculation 
# AssnMat returns a row with school assignment for each of n students
# uses DataFrames
function computePS(numRuns, assignments)
    ps = []
    df = DataFrame(assignments, :auto)
    for i in 1:ncol(df)
        counts = combine(groupby(df, i), nrow)
        counts[!, 2] = counts[:,2]/numRuns
        name="schools_person" * string(i) 
        rename!(counts, 1 => name)
        rename!(counts,:nrow => :ps)
        push!(ps, counts)
    end
    return(ps)
end

end