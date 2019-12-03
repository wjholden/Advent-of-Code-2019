using DelimitedFiles

input = readdlm("input.txt", ',', Int, '\n');
input = vec(input)

const intcode = Dict([
    (1, (f=+, n=4)),
    (2, (f=*, n=4)),
    (99, (f=Base.identity, n=1))
]);

function run(code, noun, verb)
    p::Int = 1; # instruction pointer
    c = copy(code); # copy so we can mutate the input
    c[2] = noun;
    c[3] = verb;
    while (inst = c[p]) != 99
        # Sometimes a 1-indexed language is really annoying.
        reg = (left = c[p+1], right = c[p+2], dst = c[p+3]);
        val = (left = c[reg.left + 1], right = c[reg.right + 1]);
        c[reg.dst + 1] = intcode[inst].f(val.left, val.right);
        p += intcode[inst].n
    end
    return c
end

const tests = ["1,9,10,3,2,3,11,0,99,30,40,50", "1,0,0,0,99", "2,3,0,3,99", "2,4,4,5,99,0", "1,1,1,4,99,5,6,0,99"];
#run(parse.(Int,split(tests[5],",")))

# Part 1
println("Part 1: $(run(input, 12, 2)[1])");

# Part 2
# I had hoped for something more elegant. Mathematica might have been a good way to solve
# a problem like this with symbolic computation. If I were an expert on z3 I would have
# constructed constraints.
for noun in 0:100
    for verb in 0:100
        if run(input, noun, verb)[1] == 19690720
            println("Part 2: Solution is at noun=$noun verb=$verb")
            println("Part 2: $(100 * noun + verb)");
            return 100 * noun + verb;
        end
    end
end