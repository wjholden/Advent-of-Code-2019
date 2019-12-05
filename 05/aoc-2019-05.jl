using DelimitedFiles

input = readdlm(ARGS[1], ',', Int, '\n');
input = vec(input)

inputs = Array{Int}(undef, 1)

function intcodeAdd(code, parameters, modes)
    left = modes[1] == 1 ? parameters[1] : code[parameters[1] + 1];
    right = modes[2] == 1 ? parameters[2] : code[parameters[2] + 1];
    code[parameters[3] + 1] = left + right
end

function intcodeMultiply(code, parameters, modes)
    left = modes[1] == 1 ? parameters[1] : code[parameters[1] + 1];
    right = modes[2] == 1 ? parameters[2] : code[parameters[2] + 1];
    code[parameters[3] + 1] = left * right
end

function intcodeInput(code, parameters, modes)
    code[parameters[1] + 1] = popfirst!(inputs)
end

function intcodeOutput(code, parameters, modes)
    left = modes[1] == 1 ? parameters[1] : code[parameters[1] + 1];
    println("Intcode output: $(left)")
end

function intcodeExit(code, parameters, modes)
    Base.identity("Do nothing")
end

const intcode = Dict([
    (1, (f=intcodeAdd, n=4, name="Add")),
    (2, (f=intcodeMultiply, n=4, name="Multiply")),
    (3, (f=intcodeInput, n=2, name="Input")),
    (4, (f=intcodeOutput, n=2, name="Output")),
    (99, (f=intcodeExit, n=1, name="Exit"))
]);

function run(code, noun, verb)
    p::Int = 1; # instruction pointer
    c = copy(code); # copy so we can mutate the input
    c[2] = noun;
    c[3] = verb;
    while (inst = c[p]) != 99
        opcode = inst % 100;
        parameters = view(c, (p + 1):(p + intcode[opcode].n - 1));
        modes = ((inst ÷ 100) % 10,
            (inst ÷ 1000) % 10,
            (inst ÷ 10000) % 10);
        println("$(intcode[opcode].name): $(parameters)");
        intcode[opcode].f(c, parameters, modes);
        p += intcode[opcode].n;
    end
    println(c)
    return c
end

#const tests = ["1,9,10,3,2,3,11,0,99,30,40,50", "1,0,0,0,99", "2,3,0,3,99", "2,4,4,5,99,0", "1,1,1,4,99,5,6,0,99"];
#run(parse.(Int,split(tests[4],",")), 4, 4)

# Part 1
inputs = [1]



# Unfinished, but it is time to take the kids to school.