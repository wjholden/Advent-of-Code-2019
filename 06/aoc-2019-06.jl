using DelimitedFiles, Memoize;

input = readdlm(ARGS[1], ')', String, '\n');

# The orbits dictionary is a mapping of moon -> planet -> star -> etc.
# A relation in this set means "orbits" ("(").
orbits = Dict();
foreach(i -> orbits[input[i,2]] = input[i,1], 1:size(input)[1])

# Count the orbits by exploring the graph until we reach the root.
# We can improve this by memoizing each call.
@memoize function countOrbits(object)
    #println("$(object) in orbits: $(haskey(orbits, object))")
    if haskey(orbits, object)
        return 1 + countOrbits(orbits[object])
    else
        return 0
    end
end

println("Day 6 Part 1: $(reduce(+, map(countOrbits, collect(keys(orbits)))))")
println("Day 6 Part 2:\n  Reduce your input with the following command and solve at https://wjholden.com/dijkstra")
println("""  Get-Content $(ARGS[1]) | ForEach-Object { "\$_".Replace(")", " ") + " 1"; }""")
println("  The correct answer is 2 less than the computed distance.")
