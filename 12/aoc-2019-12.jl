const regex = r"<x=(-?\d+), y=(-?\d+), z=(-?\d+)>";
const input = readlines(length(ARGS) > 0 ? ARGS[1] : "example1.txt");
pos = hcat(map(line -> parse.(Int,match(regex, line).captures), input)...);
const start = copy(pos)

function gravity(p,i,d)
    dv = 0
    for j in p[d,:]
        if p[d,i] > j
            dv -= 1
        elseif p[d,i] < j
            dv += 1
        end
    end
    return dv
end

function energy(positions, velocities, moon)
    potential = sum(abs.(positions[:,moon]))
    kinetic = sum(abs.(velocities[:,moon]))
    return (potential, kinetic, potential * kinetic)
end

vel = zeros(Int,3,4);
const period_length = zeros(Int,3)

const show_output = false

for i in 1:500000
    dv = [gravity(pos,body,dimension) for dimension in 1:3, body in 1:size(pos)[2]]
    global vel += dv
    global pos += vel
    if (show_output)
        println("After $(i) step$(i != 1 ? "s" : ""):")
        println("Positions:")
        display(pos')
        println()
        println("Velocities:")
        display(vel')
        println()
    end

    for j in 1:3
        if period_length[j] == 0 && pos[j,:] == start[j,:]
            period_length[j] = i + 1
        end
    end

    if i == 1000
        println("Day 12 Part 1: $(sum([energy(pos,vel,i)[3] for i in 1:4]))")
    end
    
    if i > 1000 && !(0 in period_length)
        break;
    end
end

println("Day 12 Part 2: $(foldl(lcm, period_length))")
