deal(a::Array{Int,1}) = reverse(a)

cut(a::Array{Int,1}, n::Int) = circshift(a, -n)

function deal(a, n)
    o = order(length(a), n)
    return [a[o[i]+1] for i=1:length(a)]
end

# Much trickier algorithm than it sounds in the question prompt.
# I haven't found a closed-form solution to this.
function order(len, stride)
    o = fill(-1, len)
    pos = -stride
    for i=0:len-1
        pos = (pos + stride) % len
        while o[pos + 1] >= 0
            pos = (pos + 1) % len
        end
        o[pos + 1] = i
    end
    return o
end

const deal_regex = r"deal with increment ([-]?\d+)"
const cut_regex = r"cut ([-]?\d+)"

function shuffle(a::Array{Int,1}, filename::String)
    commands = readlines(filename)
    for command in commands
        deal_match = match(deal_regex, command)
        cut_match = match(cut_regex, command)
        if deal_match !== nothing
            a = deal(a, parse(Int, deal_match[1]))
        elseif cut_match !== nothing
            a = cut(a, parse(Int, cut_match[1]))
        elseif command == "deal into new stack"
            a = deal(a)
        else
            println("Unmatched command: $(command)")
        end
    end
    return a
end

for example in ["example1.txt", "example2.txt", "example3.txt", "example4.txt"]
    println("$(example): $(shuffle(collect(0:9), example))")
end

print("Day 22 Part 1: ")
shuffled = shuffle(collect(0:10006), "input.txt")
println(findfirst(==(2019), shuffled) - 1)
# not 8192

# For part 2 I think it is safe to assume (from previous AoC adventures) that
# the shuffle attracts, but I have no idea how to get to it.
