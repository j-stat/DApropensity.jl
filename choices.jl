using Distributions

function choices(n, m, M, k)
    for i = 1:n
        schoolRank = schools(m, M)
        println(schoolRank) # for debugging
        priorityRank = priority(k)
        println(priorityRank) # for debugging
    end
    # todo: configure output to go into DA algorithm
end

# student chooses m schools out of possible M
function schools(m, M)
    rand(DiscreteUniform(1, M), m)
end

# school gives student 1 of its k priority rankings
function priority(k)
    rand(DiscreteUniform(1, k))
end

choices(10, 3, 5, 8)