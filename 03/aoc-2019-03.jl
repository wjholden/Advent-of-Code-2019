using DelimitedFiles

#input = readdlm("example3.txt", ',', String, '\n');
input = readdlm("input.txt", ',', String, '\n');
function parseDirection(element::String)
    return (h=element[1],
        δ=parse(Int, element[2:end]))
        # * ((element[1] == 'U' || element[1] == 'R') ? 1 : -1))
        # ((element[1] == 'U' || element[1] == 'D') ? im : 1)
end
wire1 = input[1, :];
wire2 = input[2, :];
if (wire2[end] == "")
    pop!(wire2)
end
wire1 = parseDirection.(wire1);
wire2 = parseDirection.(wire2);

function explore(turns)
    (x,y) = (0,0)
    path = Dict()
    steps = 0
    for t in turns
        d = 1
        while d <= t.δ
            if t.h == 'U'
                y = y + 1
            elseif t.h == 'D'
                y = y - 1
            elseif t.h == 'R'
                x = x + 1
            elseif t.h == 'L'
                x = x - 1
            else
                println("Found $(t.h) value that is not U, D, L, or R.")
                exit()
            end
            d = d + 1
            steps = steps + 1
            position = (x=x, y=y)
            if !(position in keys(path))
                path[position] = steps
            end
        end
    end
    return path
end

path1 = explore(wire1)
path2 = explore(wire2)
crosses = collect(intersect(keys(path1), keys(path2)))

function manhattan(p1, p2)
    return abs(p2.x - p1.x) + abs(p2.y - p1.y)
end

distances = map(p -> manhattan(p, (x=0,y=0)), crosses)
println("Part 1: $(findmin(distances)[1])")

steps = map(point -> path1[point] + path2[point], crosses)
println("Part 2: $(findmin(steps)[1])")

# Whew, this one was pretty difficult! I had wanted to use tricky linear algebra.
# Glad I didn't -- the procedural method would have been the only feasible way to 
# get the steps in part 2.
