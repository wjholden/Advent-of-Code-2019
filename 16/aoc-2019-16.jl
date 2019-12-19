using Memoize

@memoize function pattern(i::Int)
    vcat(zeros(Int,i), ones(Int,i), zeros(Int,i), fill(-1, i))
end

function pattern(position::Int, element::Int)
    p = pattern(position)
    return p[(element % length(p)) + 1]
end

function fft(input::String, phases::Int)
    m = [pattern(r, c) for r=1:length(input),c=1:length(input)]
    v = parse.(Int,split(input,""))

    for i=1:phases
        v = abs.(rem.(m * v, 10))
    end

    return v
end

examples = ["80871224585914546619083218645595", "19617804207202209144916044189917",
    "69317163492948606335995924319873"]

println("Day 16 Examples: ")
for example in examples
    println("$(example) becomes $(foldl(*, map(string, fft(example,100)[1:8])))")
end

input_file = open("input.txt")
input = readline(input_file)
close(input_file)

println("Day 16 Part 1: $(foldl(*, map(string, fft(input,100)[1:8])))")
