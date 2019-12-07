using DelimitedFiles
using Combinatorics

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

function bruteForce(code)
    maxSignal = (-1, undef)
    for order in permutations(0:4)
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
        global inputs = [phaseSetting, inputSignal];
        run(c)
        inputSignal = popfirst!(outputs)
    end
    return inputSignal
end

const examples = ["3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0",
"3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0",
"3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0"]

#for ex in examples
#    code = parse.(Int,split(ex,","));
#    println(map(order -> bruteForce(code, order), permutations(0:4)))
#end

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

Day 1 Part 1:
----------------;
1101,0,0,1,     ; vm[1] = 0 + 0 (vm[1] := counter for inputs)
1101,0,0,2,     ; vm[2] = 0 + 0 (vm[2] := register for inputs)

; brute force division gadget.
function(value, divisor)
vm[multiplier] = 0
vm[product] = vm[multiplier] * divisor
ilt(vm[product], value) vm[jump] = 1
jump-if-true vm[jump] end
vm[multiplier] = vm[multiplier] + 1
jump-if-true vm[multiplier]
:end
output(vm[multiplier])

=#

for i in 1:length(examples)
    print("Day 7 Example $(i): ");
    println(bruteForce(parse.(Int,split(examples[i],","))))
end

print("Day 7 Part 1:    ");
println(bruteForce(vec(readdlm("input.txt", ',', Int, '\n'))))
