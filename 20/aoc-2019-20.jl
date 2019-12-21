using LightGraphs

const input = map(l -> split(l, ""), readlines(length(ARGS) == 0 ? "example1.txt" : ARGS[1]))
const m = length(input) - 4
const n = length(input[1]) - 4

function vertex_id(i, j)
    #return input[i][j] == "." ? (i + j * im) : 0
    return input[i][j] == "." ? (1 + (i - 3)n + j - 3) : 0
end

# Assign numeric names to positions in the maze.
const v = [vertex_id(i + 3,j + 3) for i=0:m-1, j=0:n-1]
if length(v) < 1000
    display(v)
    println()
end

# Construct a simple graph of adjacent positions.
# The graph will be initialized with a much larger capacity for vertices than
# it needs. Hopefully the implementation uses a sparse array.
G = Graph(length(v))

for row in 1:(size(v)[1]-1)
    for col in 1:(size(v)[2]-1)
        current = v[row, col]
        if current > 0
            right = v[row + 1, col]
            down = v[row, col + 1]
            if right > 0
                add_edge!(G, current, right) || throw(Exception("Could not insert edge"))
            end
            if down > 0
                add_edge!(G, current, down) || throw(Exception("Could not insert edge"))
            end
        end
    end
end

# Identify the portals and join them.
const portals = Dict()
for row in 3:length(input)-2
    for col in 3:length(input[1])-2
        if input[row][col] == "."
            label = ""
            # letters above
            if isletter(input[row-1][col][1]) && isletter(input[row-2][col][1])
                label = input[row-2][col][1] * input[row-1][col][1]
            # letters below
            elseif isletter(input[row+1][col][1]) && isletter(input[row+2][col][1])
                label = input[row+1][col][1] * input[row+2][col][1]
            # letters left
            elseif isletter(input[row][col-1][1]) && isletter(input[row][col-2][1])
                label = input[row][col-2][1] * input[row][col-1][1]
            # letters right
            elseif isletter(input[row][col+1][1]) && isletter(input[row][col+2][1])
                label = input[row][col+1][1] * input[row][col+2][1]
            end
            if label != ""
                #print("Found portal $(label) at M[$(row),$(col)]")
                #println(" (id=$(vertex_id(row,col)))")
                if !(haskey(portals, label))
                    portals[label] = Array{Int,1}(undef, 0)
                end
                push!(portals[label], vertex_id(row, col))
            end
        end
    end
end

for kv in portals
    length(last(kv)) == 2 && (add_edge!(G, last(kv)[1], last(kv)[2]) ||
        throw(Exception("Unable to insert edge")))
end

#println(collect(edges(G)))

spf = dijkstra_shortest_paths(G, first(portals["AA"]))
println("Day 20 Part 1: $(spf.dists[first(portals["ZZ"])])")
