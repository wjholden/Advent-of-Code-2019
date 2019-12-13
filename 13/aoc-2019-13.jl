using IntcodeVM;
using DelimitedFiles;
using Sockets;
using OffsetArrays;

const code = vec(readdlm(length(ARGS) >= 1 ? ARGS[1] : "input.txt", ',', Int, '\n'))
const port = length(ARGS) >= 2 ? parse(Int,  ARGS[2]) : 60000
const width = 42
const height = 20
const screen = OffsetArray(Array{Char,2}(undef,20,42), 0:(height-1), 0:(width-1))
#const tiles = OffsetArray([ ' ', '■', '□', '-', '∘' ], 0:4)
const tiles = OffsetArray([ ' ', '■', '▦', '—', '•' ], 0:4)

if length(ARGS) >= 3 && ARGS[3] == "interactive"
    code[1] = 2;
    println("Interactive mode")
    IntcodeVM.run(code, in=stdin, out=stdout)
    exit()
elseif length(ARGS) >= 3 && ARGS[3] == "synchronous"
    code[1] = 2;
    println("Synchronous mode. Use ncat to connect on port $(port).")
    vm_listener = listen(port)
    vm_socket = accept(vm_listener)
    IntcodeVM.run(code, in=vm_socket, out=vm_socket)
    close(vm_listener)
    close(vm_socket)
    exit()
end

function read_screen(s)
    values_read = []

    # This construct is not safe for part 2.
    # For readline() to return "" the socket needs to be closed or an explicit CTRL+Z
    # needs to be sent. This works in part 1, but it is true for part 2.

    while (value = readline(s)) != ""
        if length(value) > 0
            push!(values_read, parse(Int, value))
        end
    end

    if length(values_read) % 3 != 0
        throw(Exception("Read $(length(values_read)) values"))
    end
    return values_read
end

function parse_screen(values_read)
    for i in 1:3:length(values_read)
        x = values_read[i]
        y = values_read[i+1]
        v = values_read[i+2]
        if x == -1 && y == 0
            global score = v
        else
            screen[y,x] = tiles[v]
        end
    end

    for y in 0:(height-1)
        for x in 0:(width-1)
            print(screen[y,x])
        end
        println()
    end

    return screen
end

@async begin
    vm_listener = listen(port)
    vm_socket = accept(vm_listener)
    IntcodeVM.run(code, in=vm_socket, out=vm_socket)
    close(vm_listener)
    close(vm_socket)
end

client_socket = connect(port)
parse_screen(read_screen(client_socket))
println("Day 13 Part 1: $(count(x -> x == '▦', values(screen)))")
close(client_socket)

### Now for part 2.
score = 0

@async begin
    vm_listener = listen(port + 1)
    vm_socket = accept(vm_listener)
    code[1] = 2
    println("accepted")
    IntcodeVM.run(code, in=vm_socket, out=vm_socket)
    close(vm_listener)
    close(vm_socket)
end

println("Connect on port $(port + 1) using the Java GUI app for part 2.")
readline()
exit()
