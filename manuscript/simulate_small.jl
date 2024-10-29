#using DAPropensity
include("../src/DAPropensity.jl")
using DataFrames
using Random
using CSV
using Serialization

Random.seed!(555888)
numStudents=1000
numSchools=5
totalSchools=16
numRankings=6
numRuns=500
#numRuns=20
demos = DataFrame(schoolID=collect(1:16), school_type=repeat(["type 1", "type 2"],8))
students, schools = DAPropensity.choices(numStudents, numSchools, totalSchools, numRankings)

# numRuns needs to be same between assnMat and ps
print("Running assnMat")
assnMat = DAPropensity.simulate(numRuns, students, schools, rand((25,250),totalSchools))
print("Running computePS")
ps = DAPropensity.computePS(numRuns, assnMat)
print("Running aggregatePS")
ps_type = DAPropensity.aggregatePS(demos, ps)
CSV.write("ps.csv", ps)
CSV.write("ps_type.csv", ps_type)
Serialization.serialize("assnMat", assnMat)