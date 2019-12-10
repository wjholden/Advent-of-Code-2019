using LinearAlgebra
using DataStructures

const positions = map(line -> findall("#", line),
    readlines(length(ARGS) > 0 ? ARGS[1] : "example1.txt"))
const asteroids = Array{Vector,1}(undef,0)
for i in 1:length(positions)
    for j in 1:(length(positions[i]))
        push!(asteroids, Vector([positions[i][j][1] - 1, i - 1]))
    end
end

function direction(a, b)
    # Aha! Burned by a rounding error!
    v = [a[2] - b[2], b[1] - a[1]]
    normalized = v / norm(v)
    d = atand(normalized[2], normalized[1])
    # change to north-up azimuth increasing clockwise.
    #d = (450.0 - d) % 360.0
    d = (360 + d) % 360;
    return round(d, digits=3)
end

function directions(asteroids, a)
    return map(b -> direction(a, b), filter(b -> b != a, asteroids))
end

print("Day 10 Part 1: ");
v = findmax(map(a -> length(unique(directions(asteroids, a))), asteroids))
laser = asteroids[v[2]]
println("$(v[1]) are visible from $(laser)")

function print_field(a)
    xmin = findmin([x[1] for x in a])[1]
    xmax = findmax([x[1] for x in a])[1]
    ymin = findmin([y[1] for y in a])[1]
    ymax = findmax([y[1] for y in a])[1]
    for y in ymin:ymax
        for x in xmin:xmax
            print([x,y] in a ? '#' : '.')
        end
        println()
    end
end

#print_field(asteroids)

#for b in filter(x -> x != laser, asteroids)
#    println("angle from $(laser) to $(b) is $(direction(laser, b))")
#end

q = SortedDict()
for b in asteroids
    if b != laser
        d = direction(laser, b)
        if !(d in keys(q))
            q[d] = []
        end
        push!(q[d], b)
    end
end


# Well, that was ugly, but now we have a relation of angle -> [points].
# Next, we need to sort the points by their distance to the laser.
for target in values(q)
    sort!(target, by=(x -> norm(x - laser)))
end

const print_these = [1,2,3,10,20,50,100,199,200,201,299];
const th = Dict(1 => "st", 2 => "nd", 3 => "rd");

# Now spin the laser, remove the closest vertex each time, until we reach i == 200.
i = 0
while length(q) > 0
    for targets in keys(q)
        #println("   $(targets) => $(q[targets]): ");
        target = popfirst!(q[targets])
        if isempty(q[targets])
            delete!(q, targets)
        end
        global i += 1
        if i == 200
            global vaporize = target
        end
        if i in print_these
            println("The $(i)$(get(th, i, "th")) asteroid to be vaporized is at $(target[1]),$(target[2]).")
        end
    end
end

println("Day 10 Part 2: $(vaporize[1] * 100 + vaporize[2])")