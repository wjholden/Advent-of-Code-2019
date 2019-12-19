using IntcodeVM, DelimitedFiles

const code = vec(readdlm("input.txt", ',', Int, '\n'))
tractor_beam = [last(last(IntcodeVM.run(code, inputs=[x,y]))) for x=0:49, y=0:49]

print("Day 19 Part 1: ")
println(count(==(1), tractor_beam))

# It would be computationally crazy to try to brute force this.
# This looks like something solvable through linear regression.