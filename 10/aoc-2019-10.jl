using LinearAlgebra

const positions = map(line -> findall("#", line),
    readlines(length(ARGS) > 0 ? ARGS[1] : "example1.txt"))
const asteroids = Array{Vector,1}(undef,0)
for i in 1:length(positions)
    for j in 1:(length(positions[i]))
        push!(asteroids, Vector([i - 1, positions[i][j][1] - 1]))
    end
end

function direction(a, b)
    # Aha! Burned by a rounding error!
    return round.((b - a) / norm(b - a), digits=5)
end

function directions(asteroids, a)
    return map(b -> direction(a, b), filter(b -> b != a, asteroids))
end

print("Day 10 Part 1: ");
println(findmax(map(a -> length(unique(directions(asteroids, a))), asteroids))[1])

