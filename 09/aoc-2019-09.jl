import Pkg;
Pkg.activate("IntcodeVM/");
using IntcodeVM;
using DelimitedFiles;

print("Day 9 Part 1: ");
IntcodeVM.run(vec(readdlm(ARGS[1], ',', Int, '\n')), inputs=[1], out=stdout)

print("Day 9 Part 2: ");
IntcodeVM.run(vec(readdlm(ARGS[1], ',', Int, '\n')), inputs=[2], out=stdout)
