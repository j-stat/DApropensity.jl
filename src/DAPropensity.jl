module DAPropensity

using Distributions
using Random
using DeferredAcceptance
using DataFrames
using CSV

"""
    simulate(numTimes, students, schools, capacities)

Simulates the DA mechanism with lottery `numTimes` given a student preference matrix,
school priority matrix, and school capacity list.

# Examples
```julia-repl
julia> assnMat = DAPropensity.simulate(2, [[1,2] [2,1] [1,999]], [[1,2,3] [1,2,2]], [1,2])
```
"""
function simulate(numTimes, students, schools, capacities, verbose=false)
    assnMat = Array{Int}(undef, numTimes, size(schools)[1])
    Threads.@threads :static for i in 1:numTimes
        schools_tiebroken = DeferredAcceptance.singletiebreaking(schools)
        students_tiebroken = DeferredAcceptance.singletiebreaking(students)
        assn, _ = deferredacceptance(students_tiebroken, schools_tiebroken, capacities, verbose=verbose)
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
    Threads.@threads :static for i = 1:numStudents
        student = studentRanking(numSchools, totalSchools, maxRank)
        students[:,i] = student
    end

    schools = Array{Int}(undef, numStudents, totalSchools)
    Threads.@threads :dynamic for i = 1:totalSchools
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
function computePS(assignments)
    numRuns = dim(assignments)
    ps = []
    df = DataFrame(assignments, :auto)
    Threads.@threads :static for i in 1:ncol(df)
        counts = combine(groupby(df, i), nrow)
        counts[!, 2] = counts[:,2]/numRuns
        person="person"*string(i)
        name="school"
        rename!(counts, 1 => name)
        rename!(counts,:nrow => :ps)
        counts[:, "person"] .= person
        select!(counts, :person, Not([:person, :ps]), :ps)
        push!(ps, counts)
    end
    return(ps)
end

function aggregatePS(schoolDemo, ps_list)
    # Need to update this to accept and act on variable names as input but 
    # right now instruct user to have variables called schoolID and school_type in their school demo file 
    ps_types = []
    Threads.@threads :static for i in 1:length(ps_list)
        person="person"*string(i)
        df=leftjoin(ps_list[i], schoolDemo, on = :school => :schoolID)
        df=combine(groupby(df, :school_type), :ps => sum)
        df[:, "person"] .= person
        select!(df, :person, Not([:person, :ps_sum]), :ps_sum)
        push!(ps_types, df)
    end
    return(ps_types)
end 

function preStudents(lotteryMat)
    # End results is a school x student matrix where each row is a school, 
    # each column is a student and the entries are the students preference over schools
    idx=ncol(lotteryMat)
    for c ∈ eachcol(lotteryMat)
        replace!(c, NaN => 999)
        replace!(c, missing => 999)
    end
    df=lotteryMat[:,[1:2:idx;]]
    df=permutedims(df)
    df=Matrix(df)
    return(df)
end 

function preSchools(lotteryMat)
    # End result is a student x school matrix where each row is a student, 
    # each column is a school, and each entry/cell is a school's preference over a student
    idx=ncol(lotteryMat)
    for c ∈ eachcol(lotteryMat)
        replace!(c, NaN => 999)
        replace!(c, missing => 999)
    end
    #schools=lotteryMat[:,[1:2:idx;]]
    prefs=lotteryMat[:,[2:2:idx;]]
    df=permutedims(prefs)
    df=Matrix(df)
    return(df)
end

# Inputs 
numStudents=15
numSchools=3
totalSchools=5
numRankings=8
num_runs=15
lotteryExample = DataFrame(CSV.File("./example_data/lottery_example_complete.csv"))
lotteryExample2 = DataFrame(CSV.File("./example_data/lottery_example_missing.csv"))
# Test preprocessing functions on lottery example data 
testStudents = preStudents(lotteryExample)
testSchools = preSchools(lotteryExample)
demos = DataFrame(schoolID=[1,2,3,4,5,6], school_type=["type1", "type1", "type2", "type1", "type2", "type1"])
students, schools = choices(numStudents, numSchools, totalSchools, numRankings)
assnMat = simulate(num_runs, students, schools, rand((1,3),totalSchools))
ps = computePS(assnMat)
ps_type = aggregatePS(demos, ps)

end