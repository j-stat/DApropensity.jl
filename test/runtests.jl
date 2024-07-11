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