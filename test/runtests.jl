using DAPropensity
using Test

@testset "test studentRanking" begin
    @test maximum(DAPropensity.studentRanking(5,15,999))==999
    @test maximum(DAPropensity.studentRanking(5,15,2000))==2000
    @test maximum(DAPropensity.studentRanking(15,15,2000))==15
    @test maximum(DAPropensity.studentRanking(20,15,2000))==15
    @test length(DAPropensity.studentRanking(5,15,999))==15
    @test length(DAPropensity.studentRanking(5,20,999))==20
    @test allunique(DAPropensity.studentRanking(14,15,2000))==true
end

@testset "test priorityRanking" begin
    @test DAPropensity.priorityRanking([1,2,3,999,999],1,999) == [1,1,1,999,999]
    @test DAPropensity.priorityRanking([1,2,3,2000],5,2000)[4] == 2000
    @test DAPropensity.priorityRanking([1,2,3,2000],1,999)[4] == 1
    @test allunique(DAPropensity.priorityRanking([1,2,3,4,5,6,2000],4,2000)) == false
end

@testset "test choices" begin
    @test length(DAPropensity.choices(15,5,6,8))==2
    @test size(DAPropensity.choices(15,5,6,8)[1])==(6,15)
    @test size(DAPropensity.choices(15,5,6,8)[2])==(15,6)
    @test maximum(DAPropensity.choices(15,5,6,8)[1])==999
    @test maximum(DAPropensity.choices(15,5,6,8,2000)[1])==2000
    @test maximum(DAPropensity.choices(15,6,6,8)[1])==6
    @test size(DAPropensity.choices(25,5,6,8)[1])==(6,25)
    @test size(DAPropensity.choices(25,5,20,8)[2])==(25,20)
end

@testset "test simulate" begin
    # 15 students, 5 schools each choosing, 6 total schools, 8 rankings
    students, schools = DAPropensity.choices(15,5,6,8)
    @test size(DAPropensity.simulate(5,students,schools,[3,3,3,2,2,2]))==(5,15) # 5 runs, 15 students
end 

@testset "test computeps" begin 
    # length of ps object should equal dimension of assnMat, ps scores should be in [0,1]
    numStudents=15
    numSchools=3
    totalSchools=5
    numRankings=8
    num_runs=15
    lotteryExample = DataFrame(CSV.File("./example_data/lottery_example_complete.csv"))
    testStudents = preStudents(lotteryExample)
    testSchools = preSchools(lotteryExample)
    demos = DataFrame(schoolID=[1,2,3,4,5,6], school_type=["type1", "type1", "type2", "type1", "type2", "type1"])
    students, schools = choices(numStudents, numSchools, totalSchools, numRankings)
    assnMat = simulate(num_runs, schools, students, rand((1,3),totalSchools))
    ps = computePS(assnMat)
    check = []
    for i in 1:length(ps)
        push!(check, ps[i][:,3])
    end 
    check = reduce(vcat, check)
    @test length(ps)==dim(assnMat)
    @test minimum(check)>=0
    @test maximum(check)<=1
end 
