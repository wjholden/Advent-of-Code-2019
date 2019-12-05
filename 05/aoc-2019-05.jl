using DelimitedFiles

inputs = Array{Int}(undef, 1);
outputs = [];

function modalize(code, parameters, modes)
    # an effort to make the ternary instructions a little less repetitive.
    left = modes[1] == 1 ? parameters[1] : code[parameters[1] + 1];
    right = modes[2] == 1 ? parameters[2] : code[parameters[2] + 1];
    return (left, right)
end

function intcodeAdd(code, parameters, modes, p::Int)
    (left, right) = modalize(code, parameters, modes)
    code[parameters[3] + 1] = left + right
    return p + intcode[code[p] % 100].n
end

function intcodeMultiply(code, parameters, modes, p::Int)
    (left, right) = modalize(code, parameters, modes)
    code[parameters[3] + 1] = left * right
    return p + intcode[code[p] % 100].n
end

function intcodeInput(code, parameters, modes, p::Int)
    code[parameters[1] + 1] = popfirst!(inputs)
    return p + intcode[code[p] % 100].n
end

function intcodeOutput(code, parameters, modes, p::Int)
    left = modes[1] == 1 ? parameters[1] : code[parameters[1] + 1];
    #println("Intcode output: $(left)")
    push!(outputs, left)
    return p + intcode[code[p] % 100].n
end

function intcodeJumpIfTrue(code, parameters, modes, p::Int)
    (left, right) = modalize(code, parameters, modes)
    if left != 0
        return right + 1
    else
        return p + intcode[code[p] % 100].n
    end
end

function intcodeJumpIfFalse(code, parameters, modes, p::Int)
    (left, right) = modalize(code, parameters, modes)
    if left == 0
        return right + 1
    else
        return p + intcode[code[p] % 100].n
    end
end

function intcodeLessThan(code, parameters, modes, p::Int)
    (left, right) = modalize(code, parameters, modes)
    code[parameters[3] + 1] = Int(left < right);
    return p + intcode[code[p] % 100].n
end

function intcodeEquals(code, parameters, modes, p::Int)
    (left, right) = modalize(code, parameters, modes)
    code[parameters[3] + 1] = Int(left == right);
    return p + intcode[code[p] % 100].n
end

function intcodeExit(code, parameters, modes, p::Int)
    Base.identity("Do nothing")
    return p + intcode[code[p] % 100].n
end

const intcode = Dict([
    (1, (f=intcodeAdd, n=4, name="Add")),
    (2, (f=intcodeMultiply, n=4, name="Multiply")),
    (3, (f=intcodeInput, n=2, name="Input")),
    (4, (f=intcodeOutput, n=2, name="Output")),
    (5, (f=intcodeJumpIfTrue, n=3, name="Jump-if-true")),
    (6, (f=intcodeJumpIfFalse, n=3, name="Jump-if-false")),
    (7, (f=intcodeLessThan, n=4, name="Less than")),
    (8, (f=intcodeEquals, n=4, name="Equals")),
    (99, (f=intcodeExit, n=1, name="Exit"))
]);


function run(code, noun=missing, verb=missing)
    c = copy(code); # copy so we can mutate the input
    c[2] = noun;
    c[3] = verb;
    return run(c);
end

function run(code)
    p::Int = 1; # instruction pointer
    global outputs = []
    while (inst = code[p]) != 99
        #println(c)
        opcode = inst % 100;
        parameters = view(code, (p + 1):(p + intcode[opcode].n - 1));
        modes = ((inst ÷ 100) % 10,
            (inst ÷ 1000) % 10,
            (inst ÷ 10000) % 10);
        #println("{IP=$(p)} $(intcode[opcode].name) ($(inst)): $(parameters)");
        p = intcode[opcode].f(code, parameters, modes, p);
    end
    #println(c)
    return code
end

const day2_tests = ["1,9,10,3,2,3,11,0,99,30,40,50", "1,0,0,0,99", "2,3,0,3,99", "2,4,4,5,99,0", "1,1,1,4,99,5,6,0,99"];
#run(parse.(Int,split(tests[5],",")), 1, 1)

day2 = vec(readdlm("../02/input.txt", ',', Int, '\n'));
day2_part1 = run(day2, 12, 2)[1]
println("Day 2 Part 1: $(day2_part1) ($(day2_part1 == 3409710 ? "passed" : "failed"))");

for noun in 0:100
    for verb in 0:100
        if run(day2, noun, verb)[1] == 19690720
            println("Day 2 Part 2: $(100 * noun + verb) at noun=$noun verb=$verb (expected 7912)");
            return 100 * noun + verb;
        end
    end
end

const day5_test = ["1002,4,3,4,33"];
const day5_test_result = run(parse.(Int,split(day5_test[1],",")));
println("Day 5 Test: $(day5_test_result) ($(day5_test_result == [1002, 4, 3, 4, 99] ? "passed" : "failed"))");

inputs = [1];
input = readdlm(ARGS[1], ',', Int, '\n');
input = vec(input)
const day5_part1 = run(input);
println("Day 5 Part 1: $(pop!(outputs)) (expected 7692125)");

const day5_part2_tests = ["3,9,8,9,10,9,4,9,99,-1,8", "3,9,7,9,10,9,4,9,99,-1,8",
    "3,3,1108,-1,8,3,4,3,99", "3,3,1107,-1,8,3,4,3,99"]
for test in day5_part2_tests
    global inputs = [1]
    global outputs = []
    result = run(parse.(Int,split(test,",")));
    println("Day 5 Test: $(result) produces outputs $(outputs)")
end

const day5_part2_jump = ["3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9", "3,3,1105,-1,9,1101,0,0,12,4,12,99,1"];
for test in day5_part2_jump
    for i in 0:1
        global inputs = [i]
        result = run(parse.(Int,split(test,",")));
        println("Day 5 Jump Test: $(result) gave outputs $(outputs) for input=[$(i)]")
    end
end    

const day5_large = "3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99"

for i in 7:9
    global inputs = [i];
    run(parse.(Int,split(day5_large, ",")))
    println("Day 5 Long Test: $(i): $(outputs)")
end

inputs = [5];
input = readdlm(ARGS[1], ',', Int, '\n');
input = vec(input)
run(input)
println("Day 5 Part 2: $(pop!(outputs)) (expected 14340395)")
