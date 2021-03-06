using IntcodeVM, Sockets, LightGraphs

const port = 60015
IntcodeVM.run_async("input.txt", port)
socket = connect(port)

const directions = [[0,1],[0,-1],[-1,0],[1,0]]
const unwind = [2, 1, 4, 3]
distances = Dict([0,0] => 0.0)
oxygen_location = [Inf, Inf]
xmin = xmax = ymin = ymax = 0

function dfs(point)
    global xmin = min(xmin, point[1])
    global xmax = max(xmax, point[1])
    global ymin = min(ymin, point[2])
    global ymax = max(ymax, point[2])
    # We are at some location (x,y).
    # We need to recursively explore in every direction.
    # Don't go back the same way you came.
    # You can tell where you can from by distance (parent is closer to start).
    for i = 1:4
        # Possible direction north/south/west/east.
        dst = directions[i] + point

        # An infinite distance to this point means we know there is a wall
        # at this location.
        get(distances, dst, NaN) == Inf && continue

        # A distance <= our current position means we have explored this
        # point before, and our current position in the DFS tree can do
        # no better.
        get(distances, dst, Inf) <= distances[point] && continue

        # We don't know what this point is. Let's try it.
        println(socket, i)
        response = parse(Int, readline(socket))

        # Hit a wall. Mark this point as infinite distance and move on.
        if response == 0
            distances[dst] = Inf
        # Repair droid moved in the requested direction.
        # Update the distance to this point and recursively continue DFS.
        else
            response == 2 && println("Found oxygen at $(dst)")
            response == 2 && global oxygen_location = dst
            distances[dst] = distances[point] + 1
            dfs(dst)
            
            # In this recursive algorithm, the position of the robot does not
            # automatically unwind. We have to explicitly bring him back to
            # the starting position.
            println(socket, unwind[i])
            
            # We expect that the robot goes back to where it came from. If it
            # doesn't then there must be a flaw in our algorithm.
            parse(Int, readline(socket)) != 0 || error("Robot should be able to return")
        end
    end
end

function print_map()
    # count backwards for y direction because your terminal prints top to bottom.
    for y=ymax:-1:ymin
        for x=xmin:xmax
            if [x,y] == oxygen_location
                print('O')
            elseif [x,y] == [0,0]
                print('@')
            elseif get(distances, [x,y], Inf) == Inf
                print('#')
            else
                print('.')
            end
        end
        println()
    end
end

dfs([0,0])
print_map()
println("Day 15 Part 1: $(distances[oxygen_location])")
close(socket)

# I need to do some more thinking about this one. Fun graph problem!
# I am tempted to try to solve this with Floyd-Warshall, but with about 800
# non-wall tiles I think this approach might not be feasible.

v = sort(collect(keys(filter(isfinite ∘ last, distances))))
G = Graph(length(v))
for i=1:length(v)
    for j=1:4
        # Interestingly, a binary search through the sorted array makes no real difference.
        # Reminds me of Bjarne Stroustrup's comments on the performance of linear searches
        # against vectors (https://www.youtube.com/watch?v=YQs6IC-vgmo).
        if length(searchsorted(v, v[i] + directions[j])) > 0
            add_edge!(G, i, searchsortedfirst(v, v[i] + directions[j]))
        end
        #if v[i] + directions[j] in v
        #    add_edge!(G, i, findfirst(==(v[i] + directions[j]), v))
        #end
    end
end

o2 = findfirst(==(oxygen_location), v)
print("Day 15 Part 2: ")
print(findmax(floyd_warshall_shortest_paths(G).dists[o2,:])[1])
println(" (using Floyd-Warshall!)")

# In retrospect, this was super overkill. When I started thinking about part 2
# I incorrectly assumed we needed the longest of all optimal paths in the network
# and somehow got mentally stuck on All-Pairs. Really you just need to run any
# SPF algorithm against the oxygen location. I think someone else figured out
# an even more clever way to do this but I have not looked at the Reddits.
