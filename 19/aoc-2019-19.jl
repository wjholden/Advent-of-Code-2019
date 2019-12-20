using IntcodeVM, DelimitedFiles, Memoize

@memoize function gravity(x::Int,y::Int)
    return last(last(IntcodeVM.run(code, inputs=[x,y])))
end

const code = vec(readdlm("input.txt", ',', Int, '\n'))
tractor_beam = [gravity(x,y) for x=0:49, y=0:49]

print("Day 19 Part 1: ")
println(count(==(1), tractor_beam))

# It would be computationally crazy to try to brute force this.
# This looks like something solvable through linear regression.

# We can perform a linear search for values xmin <= x <= xmax where gravity(x,y)==1
# and xmin + 100 == xmax.
# For such values, we don't actually need to search the entire square,
# just (xmin, y), (xmax, y), (xmin, y + 100).
# In fact, that might be lightweight enough to compute through
# brute force.

# We can look at the graphic and see that the solution is going to align
# to the right. So, we should probably find a pure function y=f(xmax) to
# predict where the right side of the triangle is.
# So there you have it: run linear regression along right side.

function get_bounds(y)
    xmin, xmax = 0, 0
    while gravity(xmin, y) == 0
        xmin += 1
    end
    xmax = xmin
    while gravity(xmax + 1, y) == 1
        xmax += 1
    end
    return xmin, xmax
end

function print_beam(a)
    xmax,ymax = size(a)
    for y=1:ymax
        for x=1:xmax
            print(a[x,y])
        end
        # 1-indexed languages are so annoying sometimes.
        y >= 7 && print(" $(get_bounds(y - 1))")
        println()
    end
end

print_beam(tractor_beam)