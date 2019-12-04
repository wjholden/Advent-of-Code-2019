function splitInt(i::Int)
    a = []
    while 0 < i
        pushfirst!(a, i % 10)
        i = i ÷ 10
    end
    return a
end

#lower = parse(Int, ARGS[1])
#upper = parse(Int, ARGS[2])
lower = 271973
upper = 785961

# Rule 1: must contain at least one consecutive bit string
containsConsecutive(a) = (a[1] == a[2]) || (a[2] == a[3]) ||
    (a[3] == a[4]) || (a[4] == a[5]) || (a[5] == a[6])

increasing(a) = a[1] <= a[2] <= a[3] <= a[4] <= a[5] <= a[6]

function scanGroups(a::Int)
    return scanGroups(splitInt(a), 1)
end

function scanGroups(a, start::Int)
    if length(a) < start
        return true
    else
        i = start
        c = a[i]
        while i <= length(a) && a[i] == c
            i = i + 1
        end
        return (2 < i - start && (i - start) % 2 == 1) ? false : scanGroups(a, i)
    end
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

grouped = filter(scanGroups, combinations)
println("Part 2: $(length(grouped))")
println(grouped)
# part 2 is not 358. Also not 507 (too low) or 548 (too low)
# This program does NOT produce a correct answer. I don't know why not,
# but I need to run to work now.