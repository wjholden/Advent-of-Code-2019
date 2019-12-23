using IntcodeVM, Sockets, OffsetArrays

const code = IntcodeVM.load_intcode("input.txt")
const queues = OffsetArray([[(i, -1)] for i=0:49], 0:49)

# Spin up 50 instances of the VM.
foreach(i -> IntcodeVM.run_async(code, 60000 + i), 0:49)

# Connect to all 50 VMs on TCP.
const sockets = OffsetArray([connect(60000 + i) for i=0:49], 0:49)

# Part 1 asks for the value when we first encounter destination address 255.
first_255_seen = false

# The current (x,y) values sent to 255. This value can be overwritten.
nat = (missing, missing)

# The most recent NAT value sent to address 0 when the network was idle.
last_nat = undef

# Switch values read from a VM to the appropriate destination.
# These writes are not atomic. I could envision a race condition where
# the main loop sends a packet to a VM, then moves to the next queue
# and sends another packet to a different VM, and the second response
# makes it to the switching thread first. In practice, however,
# this function is good enough to reliably get the correct answer.
function switch(socket::IO)
    @async begin
        while isopen(socket)
            (dst, x, y) = [parse(Int, readline(socket)) for i=1:3]
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

# Start the switching threads.
foreach(switch, sockets)

# Assign addresses to each VM.
foreach(i -> println(sockets[i], i), 0:49)

# Iterate across all queues repeatedly.
# Terminate the outer loop when we find the part 2 answer.
for i=0:1000
    idle = true

    # Iterate over each queue, sending (x,y) "packets" if present and -1 otherwise.
    for j=0:49
        if !isempty(queues[j])
            (x,y) = popfirst!(queues[j])
            println(sockets[j], x)
            println(sockets[j], y)
            idle = false
        else
            println(sockets[j], -1)
        end
    end

    # The network is considered "idle" when all queues are empty.
    if idle
        if nat == last_nat
            println("Day 23 Part 2: $(nat[2])")
            break
        else
            push!(queues[0], nat)
            global last_nat = nat
        end
    end
end

foreach(close, sockets)
