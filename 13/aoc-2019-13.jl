using IntcodeVM;
using DelimitedFiles;
using Sockets;

const code = vec(readdlm(length(ARGS) >= 1 ? ARGS[1] : "input.txt", ',', Int, '\n'))
const port = length(ARGS) >= 2 ? parse(Int,  ARGS[2]) : 60000

const tiles = Dict(
    0 => ' ',
    1 => '■',
    2 => '□',
    3 => '-',
    4 => '∘'
)

@async begin
    vm_listener = listen(port)
    vm_socket = accept(vm_listener)
    output = IntcodeVM.run(code, in=vm_socket, out=vm_socket)
    close(vm_listener)
    close(vm_socket)
end

function read_screen(client_socket)
    values_read = []
    while (value = readline(client_socket)) != ""
        if length(value) > 0
            #println(value)
            push!(values_read, parse(Int, value))
        end
    end

    if length(values_read) % 3 != 0
        throw(Exception("Read $(length(values_read)) values"))
    end
    return values_read
end

function parse_screen(values_read)
    screen = Dict()
    maxx = 0;
    maxy = 0;
    for i in 1:3:length(values_read)
        x = values_read[i]
        y = values_read[i+1]
        v = values_read[i+2]
        maxx = max(maxx, x)
        maxy = max(maxy, y)
        screen[(x,y)] = tiles[v]
    end

    for y in 0:maxy
        for x in 0:maxx
            print(get(screen, (x,y), '∅'))
        end
        println()
    end

    return screen
end

const client_socket = connect(port)
screen = parse_screen(read_screen(client_socket))
println("Day 13 Part 1: $(count(x -> x == '□', values(screen)))")

close(client_socket)
