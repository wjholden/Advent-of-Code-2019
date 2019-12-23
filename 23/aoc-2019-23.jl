using IntcodeVM, Sockets, OffsetArrays

const code = IntcodeVM.load_intcode("input.txt")

const queues = OffsetArray([[(i, -1)] for i=0:49], 0:49)

# Spin up 50 instances of the VM.
for i=0:49
    IntcodeVM.run_async(code, 60000 + i)
end

# Connect to all 50 on TCP.
const sockets = OffsetArray([connect(60000 + i) for i=0:49], 0:49)

first_255_seen = false
nat = (missing, missing)

# Switch values read from a VM to the appropriate destination.
# There is no real guarantee that this occurs atomically...
function switch(socket::IO)
    @async begin
        while isopen(socket)
            (dst, x, y) = [parse(Int, readline(socket)) for i=1:3]
            #print("[RX] ")
            #println((dst, x, y))
            if dst != 255
                push!(queues[dst], (x,y))
            elseif !first_255_seen && dst == 255
                println("Day 23 Part 1: $(y)")
                global first_255_seen = true
                global nat = (x,y)
            else
                global nat = (x,y)
            end
        end
    end
end

# Start the switching thread.
foreach(switch, sockets)

# Assign addresses
foreach(i -> println(sockets[i], "$(i)"), 0:49)

last_nat = undef

# Looks like this problem does not require true concurrency.
for i=0:1000
    idle = true

    for j=0:49
        if !isempty(queues[j])
            (x,y) = popfirst!(queues[j])
            #print("[TX $(j)] ")
            #println((x,y))
            println(sockets[j], x)
            println(sockets[j], y)
            idle = false
        else
            println(sockets[j], -1)
        end
    end

    if idle
        #println("Network is idle, NAT=$(nat)")
        if nat == last_nat
            println("Day 23 Part 2: $(nat[2])")
            exit()
        else
            push!(queues[0], nat)
            global last_nat = nat
        end
    end
end
