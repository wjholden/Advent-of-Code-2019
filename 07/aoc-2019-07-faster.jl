using IntcodeVM;
using DelimitedFiles;
using Combinatorics;

using Sockets;

listeners = [listen(60000 + i) for i in 1:5]

readers = Array{TCPSocket,1}(undef, 5)
for i in 1:5
    @async begin
        readers[i] = accept(listeners[i])
    end
end

senders = [connect(60000 + i) for i in 1:5]

const examples = ["3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0",
"3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0",
"3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0"]

function combine_amplifiers(code, p)
    for i in 1:4
        @async begin
            inputs = (i == 1) ? [p[i] - 1, 0] : [p[i] - 1];
            IntcodeVM.run(code, in=readers[p[i]],
                out=senders[p[i + 1]], inputs=inputs);
        end
    end
    # last one is synchronous
    return last(last(IntcodeVM.run(code, in=readers[p[5]], out=devnull, inputs=[p[5] - 1])))
end

for example in examples
    code = parse.(Int,split(example,","))
    println(first(findmax(map(p -> combine_amplifiers(code, p), permutations(1:5)))))
end

print("Day 7 Part 1:    ");
code = vec(readdlm("input.txt", ',', Int, '\n'))
println(first(findmax(map(p -> combine_amplifiers(code, p), permutations(1:5)))))

foreach(close, senders)
foreach(close, readers)
foreach(close, listeners)
