bugs = Int8.(map(==("#"), hcat(split.(readlines(ARGS[1]), "")...)))'

function adjacent(m, row, col)
    get(m, (row,col+1), 0) + 
        get(m, (row,col-1), 0) + 
        get(m, (row+1,col), 0) +
        get(m, (row-1,col), 0)
end

function life(m)
    m2 = Array{Int,2}(undef, 5, 5)

    for row=1:5
        for col=1:5
            adj = adjacent(m, row, col)
            if m[row,col] == 1
                m2[row,col] = adj == 1 ? 1 : 0
            else
                m2[row,col] = (1 == adj || 2 == adj) ? 1 : 0
            end
        end
    end

    return m2
end

# Every possible state has one of 33554432 possible states.
# They can be efficiently serialized into an integer.
# This is column-major, meaning you will get one column
# at a time. It doesn't really matter as long as the "signature"
# algorithm does not change at runtime.
# Check this out:
#   a = rand(collect('a':'z'), 5, 5)
#   foldl((x,y) -> x * y, a)
biodiversity(m) =foldr((x,y) -> x+2y, m')

function render(m)
    s = ""
    for row=1:size(m)[1]
        for col=1:size(m)[2]
            s *= m[row,col] == 1 ? "#" : "."
        end
        s *= "\n"
    end
    return s
end

function test(m)
    println("Initial state:")
    print(render(m))
    println("Biodiversity rating: $(biodiversity(m))\n")

    for i=1:4
        m = life(m)
        println("After $(i) minute$(i > 1 ? "s" : ""):")
        print(render(m))
        println("Biodiversity rating: $(biodiversity(m))\n")
    end
end

#test(bugs)

seen = Set()
while true
    d = biodiversity(bugs)
    if d ∈ seen
        println("Day 24 Part 1: $(d)")
        print(render(bugs))
        break
    end
    push!(seen, d)
    global bugs = life(bugs)
end
