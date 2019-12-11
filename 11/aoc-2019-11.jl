using IntcodeVM;
using DelimitedFiles;
using Combinatorics;
using Sockets;

const code = vec(readdlm(length(ARGS) >= 1 ? ARGS[1] : "input.txt", ',', Int, '\n'))
const port = length(ARGS) >= 2 ? parse(Int,  ARGS[2]) : 60000

# Open a server socket and launch the Intcode VM as a thread.
@async begin
    vm_listener = listen(port)
    vm_socket = accept(vm_listener)
    println("Connected!")
    IntcodeVM.run(code, in=vm_socket, out=vm_socket)
    close(vm_socket)
    close(vm_listener)
end

println("Hull painting robot is listening for commands on port $(port).")

position = 0
heading = im
const white = Set()
const socket = connect(port)
const colors = Dict(0 => "black", 1 => "white", "0" => "BLACK", "1" => "WHITE")
while true
    println("0: Black, 1: White")
    print("HULLPNTR.EXE> ")
    command = readline()
    if command in ["quit", "q", "exit", "bye"]
        break
    elseif command == ""
        continue
    end
    println(socket, command)
    (color, direction) = (readline(socket), readline(socket))
    println("This panel is $(colors[color]).")
    println("The robot should turn $(direction == "0" ? "left" : "right") 90 degrees.")
    println()
end

close(socket)
