# DA-in-Julia

This repository tracks the development of a package written in Julia for simulating the Deferred Acceptance (DA) aglorithm used in centralized assignment processes for assigning students to schools in large urban school districts across the U.S. By simulating the assignment process, researchers are able to derive true propensity scores that can be used for credible impact evaluation and causal analysis. 

Link to LucidChart diagram (still being updated): https://lucid.app/lucidchart/60d176de-4235-4ba8-8610-9991fba1d2b8/edit?page=0_0&invitationId=inv_08bc89f8-41b7-439b-a52b-2e1a10ffa8a3#

# Example code

```{julia}
numStudents=15
numSchools=3
totalSchools=5
numRankings=
num_runs=15
demos = DataFrame(schoolID=[1,2,3,4,5,6], school_type=["type1", "type1", "type2", "type1", "type2", "type1"])
students, schools = choices(numStudents, numSchools, totalSchools, numRankings)
assnMat = simulate(num_runs, students, schools, rand((1,3),totalSchools))
ps = computePS(num_runs, assnMat)
ps_type = aggregatePS(demos, ps)
```