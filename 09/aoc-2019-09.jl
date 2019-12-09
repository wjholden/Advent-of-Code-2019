import Pkg;
Pkg.activate("IntcodeVM/");
using IntcodeVM;

# Let's go back to day 2 part 1 for some tests.

const tests = ["1,9,10,3,2,3,11,0,99,30,40,50", "1,0,0,0,99", "2,3,0,3,99", "2,4,4,5,99,0", "1,1,1,4,99,5,6,0,99"];

for test in tests
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