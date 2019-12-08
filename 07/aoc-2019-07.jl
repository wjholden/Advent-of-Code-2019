using DelimitedFiles
using Combinatorics

STANDARD_IO = false

function modalize(code, parameters, modes)
    # an effort to make the ternary instructions a little less repetitive.
    left = modes[1] == 1 ? parameters[1] : code[parameters[1] + 1];
    right = modes[2] == 1 ? parameters[2] : code[parameters[2] + 1];
    return (left, right)
end

function intcodeAdd(code, parameters, modes, p::Int, inputs, outputs)
    (left, right) = modalize(code, parameters, modes)
    code[parameters[3] + 1] = left + right
    return p + intcode[code[p] % 100].n
end

function intcodeMultiply(code, parameters, modes, p::Int, inputs, outputs)
    (left, right) = modalize(code, parameters, modes)
    code[parameters[3] + 1] = left * right
    return p + intcode[code[p] % 100].n
end

function intcodeInput(code, parameters, modes, p::Int, inputs, outputs)
    # If the "inputs" array contains something, take it. Otherwise we can read from stdin.
    if STANDARD_IO && isempty(inputs)
        code[parameters[1] + 1] = parse(Int, readline())
    else
        code[parameters[1] + 1] = popfirst!(inputs)
    end
    return p + intcode[code[p] % 100].n
end

function intcodeOutput(code, parameters, modes, p::Int, inputs, outputs)
    left = modes[1] == 1 ? parameters[1] : code[parameters[1] + 1];
    if STANDARD_IO
        println(left)
    end
    push!(outputs, left)
    return p + intcode[code[p] % 100].n
end

function intcodeJumpIfTrue(code, parameters, modes, p::Int, inputs, outputs)
    (left, right) = modalize(code, parameters, modes)
    if left != 0
        return right + 1
    else
        return p + intcode[code[p] % 100].n
    end
end

function intcodeJumpIfFalse(code, parameters, modes, p::Int, inputs, outputs)
    (left, right) = modalize(code, parameters, modes)
    if left == 0
        return right + 1
    else
        return p + intcode[code[p] % 100].n
    end
end

function intcodeLessThan(code, parameters, modes, p::Int, inputs, outputs)
    (left, right) = modalize(code, parameters, modes)
    code[parameters[3] + 1] = Int(left < right);
    return p + intcode[code[p] % 100].n
end

function intcodeEquals(code, parameters, modes, p::Int, inputs, outputs)
    (left, right) = modalize(code, parameters, modes)
    code[parameters[3] + 1] = Int(left == right);
    return p + intcode[code[p] % 100].n
end

function intcodeExit(code, parameters, modes, p::Int, inputs, outputs)
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

function run(code, inputs=[], outputs=[])
    p::Int = 1; # instruction pointer
    while (inst = code[p]) != 99
        opcode = inst % 100;
        parameters = view(code, (p + 1):(p + intcode[opcode].n - 1));
        modes = ((inst ÷ 100) % 10,
            (inst ÷ 1000) % 10,
            (inst ÷ 10000) % 10);
        p = intcode[opcode].f(code, parameters, modes, p, inputs, outputs);
    end
    return (code,outputs)
end

function bruteForce(code, phaseSettings::UnitRange{Int})
    maxSignal = (-1, undef)
    for order in permutations(phaseSettings)
        signal = chainAmplifiers(code, order)
        if (signal > maxSignal[1])
            maxSignal = (signal, order)
        end
    end
    return maxSignal
end

function chainAmplifiers(code, sequence)
    inputSignal = 0
    for phaseSetting in sequence
        c = copy(code)
        inputSignal = popfirst!(run(c, [phaseSetting, inputSignal], [])[2])
    end
    return inputSignal
end

const examples = ["3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0",
"3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0",
"3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0"]

#=
Example 1:
----------------;
3,15,           ; input and store at vm[15]
3,16,           ; input and store at vm[16]
1002,16,10,16,  ; vm[16] = vm[16] * 10
                ; (2nd parameter is in immediate mode)
1,16,15,15,     ; vm[15] = vm[15] + vm[16]
4,15,           ; output 15
99,0,0          ; exit
                ; (the zeros at the end are placeholders for variables vm[15] and vm[16])
----------------;

Example 2:
----------------;
3,23,           ; input and store at vm[23] 
3,24,           ; input and store at vm[24]
1002,24,10,24,  ; vm[24] = vm[24] * 10
1002,23,-1,23,  ; vm[23] = vm[23] * -1
101,5,23,23,    ; vm[23] = 5 + vm[23]
1,24,23,23,     ; vm[23] = vm[23] + vm[24]
4,23,           ; output vm[23]
99,0,0          ; exit
----------------;
=#

#= 
Usage:
For part 1, invoke this program with no command-line argument.
The program will load your input from a file named 'input.txt' in the current directory.

Part 2 uses command line arguments to initialize inputs with the intended
amplifier number. The programs 'make_commands.jl' and resulting 'commands.cmd' 
will generate all of the 5!=120 permutations needed to find the solution.
You need the 'ncat' program available in your %PATH%. The pipelines generated by 'commands.cmd'
are known to work in cmd.exe on Microsoft Windows [Version 10.0.18362.476].
The pipelines probably DO NOT work in PowerShell 5.1.18362.145 and earlier.
=#

if length(ARGS) == 0
    # To get part 1, provide no command-line arguments.
    for i in 1:length(examples)
        print("Day 7 Example $(i): ");
        println(bruteForce(parse.(Int,split(examples[i],",")), 0:4))
    end

    print("Day 7 Part 1:    ");
    println(bruteForce(vec(readdlm("input.txt", ',', Int, '\n')), 0:4))
else
    # For part 2, provide two command-line arguments.
    # The first is the source code you want to run.
    # The second through final arguments will be read as input values.
    # Here, the program will read and write to the host OS stdin/stdout.
    STANDARD_IO = true
    inputs = parse.(Int, ARGS[2:end])
    run(vec(readdlm(ARGS[1], ',', Int, '\n')), inputs)

    # Here is an example chain that slowly but correctly computes 43210 from example 1:
    # julia.exe .\aoc-2019-07.jl .\example1.txt 4 0 | julia.exe .\aoc-2019-07.jl .\example1.txt 3 | julia.exe .\aoc-2019-07.jl .\example1.txt 2 | julia.exe .\aoc-2019-07.jl .\example1.txt 1 | julia.exe .\aoc-2019-07.jl .\example1.txt 0
    # Interestingly, this runs much faster in CMD.exe than PowerShell (~3 seconds vs >6 seconds on my machine).
    #
    # The below command will execute the entire pipeline, circuiting everything back over TCP with the netcat command,
    # and log the results to a file named 98765.txt. 
    # ncat -l -o 98765.txt localhost 60001 | julia aoc-2019-07.jl example4.txt 9 0 | julia aoc-2019-07.jl example4.txt 8 | julia aoc-2019-07.jl example4.txt 7 | julia aoc-2019-07.jl example4.txt 6 | julia aoc-2019-07.jl example4.txt 5 | ncat localhost 60001
    #
    # So what I have done is I wrote a Julia program to take advantage of the permutations() function.
    # The Julia program "make_commands.jl" generates a CMD script that will run every amplifier combination.
    # I saved these commands as "commands.cmd", which writes text files to the "results/" directory.
    # Glob all of these up and find the result with the following PowerShell command:
    # gc results/* | % { [int]$_; } | sort | select -last 1
end

# Whew, that one was hard! Concurrency is always a challenging topic.
