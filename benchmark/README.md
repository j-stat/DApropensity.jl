# Benchmarking results

`benchmark.jl` contains Julia code to run benchmarking for the simulation code. It is meant to give you an idea of how quickly the main function in `DAPropensity.jl`, aka `simulate`, runs. It was supposed to benchmark `computePS` and `aggregatePS` as well, but for some reason when benchmarking it segfaults, although it doesn't in regular behavior, therefore those are not computed here. In any case, the thing that mainly takes the most time is `simulate`.

Results from running it are shown below. As you can see, in most cases the function runs quite quickly, but in some cases it runs incredibly slow. In future work will try to figure out why (see issue #27).

```{julia}
using DAPropensity
using BenchmarkTools
using DataFrames

Threads.nthreads()
```

8

## Quick benchmark

```{julia}
numStudents=15
numSchools=3
totalSchools=5
numRankings=8
num_runs=500
demos = DataFrame(schoolID=[1,2,3,4,5,6], school_type=["type1", "type1", "type2", "type1", "type2", "type1"])
```

6×2 DataFrame
 Row │ schoolID  school_type 
     │ Int64     String      
─────┼───────────────────────
   1 │        1  type1
   2 │        2  type1
   3 │        3  type2
   4 │        4  type1
   5 │        5  type2
   6 │        6  type1

```{julia}
students, schools = DAPropensity.choices(numStudents, numSchools, totalSchools, numRankings)
```

([999 1 … 2 1; 999 999 … 1 999; … ; 3 2 … 999 999; 2 999 … 999 3], [999 999 … 4 7; 4 999 … 4 999; … ; 1 4 … 999 999; 3 999 … 999 8])

```{julia}
@benchmark assnMat = DAPropensity.simulate($num_runs, $students, $schools, $rand((1,3),$totalSchools))
```

BenchmarkTools.Trial: 727 samples with 1 evaluation.
 Range (min … max):  2.390 ms … 78.149 ms  ┊ GC (min … max):  0.00% … 96.42%
 Time  (median):     2.937 ms              ┊ GC (median):     0.00%
 Time  (mean ± σ):   6.876 ms ± 10.112 ms  ┊ GC (mean ± σ):  55.23% ± 30.25%

  █▆▄▂                                                 ▁▁     
  █████▄▁▁▁▄▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▅▅██████ ▇
  2.39 ms      Histogram: log(frequency) by time     33.4 ms <

 Memory estimate: 40.56 MiB, allocs estimate: 525044.

 ```{julia}
 @benchmark assnMat = DAPropensity.simulate(100000, $students, $schools, $rand((1,3),$totalSchools))
 ```

 BenchmarkTools.Trial: 4 samples with 1 evaluation.
 Range (min … max):  1.249 s …   1.400 s  ┊ GC (min … max): 58.10% … 58.39%
 Time  (median):     1.283 s              ┊ GC (median):    57.98%
 Time  (mean ± σ):   1.304 s ± 68.017 ms  ┊ GC (mean ± σ):  58.12% ±  0.30%

  █    █              █                                   █  
  █▁▁▁▁█▁▁▁▁▁▁▁▁▁▁▁▁▁▁█▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁█ ▁
  1.25 s         Histogram: frequency by time         1.4 s <

 Memory estimate: 8.58 GiB, allocs estimate: 110700044.

 ## More realistic benchmark

 ```{julia}
 numStudents=2000
numSchools=10
totalSchools=30
numRankings=8
demos = DataFrame(schoolID=collect(1:30), school_type=repeat(["type 1", "type 2"],15))
students, schools = DAPropensity.choices(numStudents, numSchools, totalSchools, numRankings)

@benchmark assnMat = DAPropensity.simulate(10, $students, $schools, $rand((50,500),$totalSchools))
 ```

BenchmarkTools.Trial: 3 samples with 1 evaluation.
 Range (min … max):  1.887 s …  1.897 s  ┊ GC (min … max): 39.03% … 39.00%
 Time  (median):     1.896 s             ┊ GC (median):    39.02%
 Time  (mean ± σ):   1.893 s ± 5.195 ms  ┊ GC (mean ± σ):  39.20% ±  0.33%

  █                                               █      █  
  █▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁█▁▁▁▁▁▁█ ▁
  1.89 s        Histogram: frequency by time         1.9 s <

 Memory estimate: 12.53 GiB, allocs estimate: 7330070.