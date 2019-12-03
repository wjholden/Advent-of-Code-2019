using DelimitedFiles

input = readdlm(ARGS[1], ',', String, '\n');
parseDirection(element::String) = (h=element[1], δ=parse(Int, element[2:end]))
wire1 = input[1, :];
wire2 = input[2, :];
if (wire2[end] == "")
    pop!(wire2)
end
wire1 = parseDirection.(wire1);
wire2 = parseDirection.(wire2);

function explore(turns)
    position = 0
    path = Dict()
    inc = Dict('U' => im, 'D' => -im, 'R' => 1, 'L' => -1)
    steps = 0
    for t in turns
        for d in 1:t.δ
            position = position + inc[t.h] # Not my idea but it is clever. Saves us from switching.
            steps = steps + 1
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

manhattan(p) = abs(real(p)) + abs(imag(p))
distances = map(manhattan, crosses)
println("Part 1: $(findmin(distances)[1])")

steps = map(point -> path1[point] + path2[point], crosses)
println("Part 2: $(findmin(steps)[1])")

# Whew, this one was pretty difficult! I had wanted to use tricky linear algebra.
# Glad I didn't -- the procedural method would have been the only feasible way to 
# get the steps in part 2.
