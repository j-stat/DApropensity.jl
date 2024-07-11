using DAPropensity
using BenchmarkTools
using DataFrames

Threads.nthreads()

# quick benchmark

numStudents=15
numSchools=3
totalSchools=5
numRankings=8
num_runs=500
demos = DataFrame(schoolID=[1,2,3,4,5,6], school_type=["type1", "type1", "type2", "type1", "type2", "type1"])
students, schools = DAPropensity.choices(numStudents, numSchools, totalSchools, numRankings)

@benchmark assnMat = DAPropensity.simulate($num_runs, $students, $schools, $rand((1,3),$totalSchools))

# for some reason computePS segfaults...
#assnMat = DAPropensity.simulate(num_runs, students, schools, rand((1,3),totalSchools))
#@benchmark ps = DAPropensity.computePS(num_runs, assnMat)

#@btime DAPropensity.simulate(500, $students, $schools, $rand((1,3),$totalSchools))
@benchmark assnMat = DAPropensity.simulate(100000, $students, $schools, $rand((1,3),$totalSchools))

# more realistic but slower benchmark

numStudents=2000
numSchools=10
totalSchools=30
numRankings=8
demos = DataFrame(schoolID=collect(1:30), school_type=repeat(["type 1", "type 2"],15))
students, schools = DAPropensity.choices(numStudents, numSchools, totalSchools, numRankings)

@benchmark assnMat = DAPropensity.simulate(10, $students, $schools, $rand((50,500),$totalSchools))