function splitInt(i::Int)
    a = []
    while 0 < i
        pushfirst!(a, i % 10)
        i = i ÷ 10
    end
    return a
end

lower = parse(Int, ARGS[1])
upper = parse(Int, ARGS[2])

# Rule 1: must contain at least one consecutive bit string
containsConsecutive(a) = (a[1] == a[2]) || (a[2] == a[3]) ||
    (a[3] == a[4]) || (a[4] == a[5]) || (a[5] == a[6])

# Rule 2: digits in the string must be in non-decreasing order
increasing(a) = a[1] <= a[2] <= a[3] <= a[4] <= a[5] <= a[6]

# Rule 3 (part 2): only pairs count, not triples or longer matches.
function containsPair(i::Int)
    if i == 0 return false end
    current = i % 10
    matches = 0
    while (i ÷ (10^matches)) % 10 == current
        matches = matches + 1
    end
    return matches == 2 || containsPair(i ÷ (10^matches))
end

function countCombinations(lower::Int, upper::Int)
    combinations = Set()
    for x in lower:upper
        a = splitInt(x)
        if (containsConsecutive(a) && increasing(a))
            push!(combinations, x)
        end
    end
    return combinations
end

combinations = countCombinations(lower, upper)
println("Part 1: $(length(combinations))") # 925

grouped = filter(containsPair, combinations)
println("Part 2: $(length(grouped))")
# This one turned out to be more challenging for me than it should have.
# I had misinterpreted the specification for part 2. I thought that
# the groups could not be length 3, but that two groups of 2 next to each
# other would be OK somehow. As in, "567777" would be a satisfying assignment.
# I was wrong.
# I'm kind of OK with my algorithm to match pairs. It does not easily
# generalize to arbitrary strings.
