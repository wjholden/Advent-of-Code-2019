using Combinatorics

for sequence in permutations(5:9)
    print("ncat -l -o results/$(sequence[1])$(sequence[2])$(sequence[3])$(sequence[4])$(sequence[5]).txt localhost 60001 ");
    for i in 1:length(sequence)
        print("| julia aoc-2019-07.jl input.txt $(sequence[i]) ");
        if i == 1
            print("0 ")
        end
    end
    println("| ncat localhost 60001");
end