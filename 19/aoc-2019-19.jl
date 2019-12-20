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

@memoize function get_bounds(y)
    y < 6 && return (0,0)

    # The current xmin value can never be less than xmin value at y-1.
    xmin = first(get_bounds(y-1))
    while gravity(xmin, y) == 0
        xmin += 1
    end
    
    # Same for xmax, we can never be to the left of the right bound at y-1.
    xmax = max(xmin, last(get_bounds(y-1)))
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
        y >= 7 && print(" y=$(y-1): bounds are $(get_bounds(y - 1))")
        println()
    end
end

print_beam(tractor_beam)


# This is a linear programming question.
# We run a linear regression to predict what the left and right sides of our bounds are.
#using DataFrames, GLM;
#data_left = DataFrame(X=6:49, Y=[first(get_bounds(i)) for i=6:49])
#ols_left = lm(@formula(Y ~ X), data_left)
#data_right = DataFrame(X=6:49, Y=[last(get_bounds(i)) for i=6:49])
#ols_right = lm(@formula(Y ~ X), data_right)

# We can see from here that the right prediction is extremely accurate.
# To my disappointment, I now realize the formula is just right_bound = row - 1
#hcat([get_bounds(i) for i=6:49], predict(ols_left), predict(ols_right))
# D'oh, something goes wrong at y=216 and y=217! The right bound does not linearly increase between these rows.

function find_square(square_size::Int, search_space::UnitRange{Int})
    # Ahh, my old friend off-by-one errors.
    # We have to include the current location x or y in a square of size n.
    dy = square_size - 1
    for row=search_space
        b1 = get_bounds(row)
        b2 = get_bounds(row + dy)
        #println("Bounds(row $(row)) = $(b1), Bounds(row $(row + dy)) = $(b2)")
        #println(b1[2] - b2[1])
        if b1[2] - b2[1] == dy
            return (b2[1], row)
        end
    end
    return (-1,-1)
end

(x,y) = find_square(100, 1:10000)
println("Day 19 Part 2: $(x * 10000 + y)")