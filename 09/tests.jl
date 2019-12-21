using IntcodeVM, Combinatorics

# Let's go back to day 2 part 1 for some tests.

const day2_tests = ["1,9,10,3,2,3,11,0,99,30,40,50", "1,0,0,0,99", "2,3,0,3,99", "2,4,4,5,99,0", "1,1,1,4,99,5,6,0,99"];

for test in day2_tests
    println(IntcodeVM.run(parse.(Int,split(test,",")))[1]);
end


# And day 5

const day5_test = ["1002,4,3,4,33"];
const day5_test_result = IntcodeVM.run(parse.(Int,split(day5_test[1],",")))[1];
println("Day 5 Test: $(day5_test_result) ($(day5_test_result == [1002, 4, 3, 4, 99] ? "passed" : "failed"))");

const day5_part2_tests = ["3,9,8,9,10,9,4,9,99,-1,8", "3,9,7,9,10,9,4,9,99,-1,8",
    "3,3,1108,-1,8,3,4,3,99", "3,3,1107,-1,8,3,4,3,99"]
for test in day5_part2_tests
    (result,outputs) = IntcodeVM.run(parse.(Int,split(test,",")), inputs=[1],
            in=devnull, out=devnull);
    println("Day 5 Test: $(result) produces outputs $(outputs)")
end

# Day 7

const day7_examples = ["3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0",
"3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0",
"3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0"]

function chainAmplifiers(code, sequence)
    inputSignal = 0
    for phaseSetting in sequence
        c = copy(code)
        inputSignal = popfirst!(IntcodeVM.run(c, inputs=[phaseSetting, inputSignal], in=devnull, out=devnull)[2])
    end
    return inputSignal
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

for i in 1:length(day7_examples)
    print("Day 7 Example $(i): ");
    println(bruteForce(parse.(Int,split(day7_examples[i],",")), 0:4))
end


# Day 9!

const day9_examples = ["109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99",
"1102,34915192,34915192,7,4,7,99,0",
"104,1125899906842624,99"];

for test in day9_examples
    print("Day 9 Test: ");
    println(IntcodeVM.run(parse.(Int,split(test,",")))[2]);
end

#=
--------------------;
109,1,              ; increase relative offset by 1
204,-1,             ; output vm[-1] using the relative offset
1001,100,1,100,     ; increment vm[100] by 1
1008,100,16,101,    ; write result of (vm[100] == 16) to vm[101]
1006,101,0,         ; if vm[101] == 0 goto 0
99                  ; exit
--------------------;
=#