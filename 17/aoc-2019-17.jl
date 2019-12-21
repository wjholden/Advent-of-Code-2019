using IntcodeVM, OffsetArrays

const code = IntcodeVM.load_intcode("input.txt")

function get_puzzle()
    o = IntcodeVM.run(code)[2]
    pop!(o) # remove doubled newline at the end
    s = foldr(*, Char.(o))
    println(s)

    width = findfirst(==(Int('\n')), o)
    m = reshape(o, width, :)' # transpose because Julia is column-major
    v = view(m, :, 1:width-1) # take a view without newlines

    # zero-index array indices
    z = OffsetArray(v, 0:size(v)[1]-1, 0:size(v)[2]-1)
    return z
end

function get_example()
    v = Int.(first.(hcat((split.(readlines("example.txt"), ""))...)))'
    return OffsetArray(v, 0:size(v)[1]-1, 0:size(v)[2]-1)
end

function find_intersections(a, value)
    alignment_parameters = Array{Int,1}(undef, 0)

    for i=1:size(a)[1]-2
        for j=1:size(a)[2]-2
            if a[i,j] == a[i,j+1] == a[i,j-1] == a[i-1,j] == a[i+1,j] == value
                push!(alignment_parameters, i * j)
            end
        end
    end

    return alignment_parameters
end

maze = get_puzzle()
print("Day 17 Part 1: ")
println(sum(find_intersections(maze, Int('#'))))
