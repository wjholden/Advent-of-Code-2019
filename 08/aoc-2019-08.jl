in = parse.(Int,split(readline("input.txt"), ""))
w = 25
h = 6
l = length(in) ÷ w ÷ h
layers = reshape(in, (w, h, l))

function count_integers(a, c)
    map(layer -> length(filter(x -> x == c, a[:,:,layer])), 1:size(a)[3])
end

zero_counts = count_integers(layers, 0)
layer_with_fewest_zeros = findmin(zero_counts)[2]
ones = length(filter(x -> x == 1, layers[:, :, layer_with_fewest_zeros]))
twos = length(filter(x -> x == 2, layers[:, :, layer_with_fewest_zeros]))
println("Day 8 Part 1: $(ones * twos)")

function color(img, x, y)
    for z in 1:size(img)[3]
        # iterate until we get a color
        if img[x,y,z] == 0
            return ' '
        elseif img[x,y,z] == 1
            return '■'
        end
    end
    println(stderr, "Fully-transparent pixel at ($(x),$(y),$(z))")
    return 0
end

println("Day 8 Part 2: ")
for y in 1:size(layers)[2]
    for x in 1:size(layers)[1]
        print(color(layers, x, y))
    end
    println()
end
println()

# Very satisfying day. This was a much easier puzzle after all that Intcode yesterday!
