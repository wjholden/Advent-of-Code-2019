using IntcodeVM;
using DelimitedFiles;

# In day 9 we complete the Intcode VM and validate its correctness.
# Many Advent of Code participants (including myself) would have found
# on this day that their Intcode interpreters were under-engineered.
# The big thing people needed was encapsulation. Intcode VMs should be
# easy to start, reasonably self-contained, and easy to get output from.

print("Day 9 Part 1: ");
IntcodeVM.run(vec(readdlm(ARGS[1], ',', Int, '\n')), inputs=[1], out=stdout)

print("Day 9 Part 2: ");
IntcodeVM.run(vec(readdlm(ARGS[1], ',', Int, '\n')), inputs=[2], out=stdout)
