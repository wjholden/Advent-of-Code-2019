module IntcodeVM

mutable struct VM
    code::Array{Int,1}
    inputs::Array{Int,1}
    outputs::Array{Int,1}
    inst_ptr::Int
    input::IO
    output::IO
end

function modalize(vm::VM, parameters, modes)
    # an effort to make the ternary instructions a little less repetitive.
    left = modes[1] == 1 ? parameters[1] : vm.code[parameters[1] + 1];
    right = modes[2] == 1 ? parameters[2] : vm.code[parameters[2] + 1];
    return (left, right)
end

function intcode_write(vm::VM, dst::Int, value::Int)
    vm.code[dst] = value
end

function intcode3op(vm::VM, parameters, modes, f::Function)
    (left, right) = modalize(vm, parameters, modes)
    intcode_write(vm, parameters[3] + 1, f(left, right))
    return nextInstruction(vm);
end

function intcodeAdd(vm::VM, parameters, modes)
    return intcode3op(vm, parameters, modes, +)
end

function intcodeMultiply(vm::VM, parameters, modes)
    return intcode3op(vm, parameters, modes, *)
end

function intcodeInput(vm::VM, parameters, modes)
    # If the "inputs" array contains something, take it. Otherwise we can read from stdin.
    if isempty(vm.inputs)
        intcode_write(vm, parameters[1] + 1, parse(Int, readline(vm.input)))
    else
        intcode_write(vm, parameters[1] + 1, popfirst!(vm.inputs))
    end
    return nextInstruction(vm);
end

function intcodeOutput(vm::VM, parameters, modes)
    left = modes[1] == 1 ? parameters[1] : vm.code[parameters[1] + 1];
    println(vm.output, left)
    push!(vm.outputs, left)
    return nextInstruction(vm);
end

function intcodeJump(vm::VM, parameters, modes, condition::Function)
    (left, right) = modalize(vm.code, parameters, modes)
    if condition(left)
        return right + 1
    else
        return nextInstruction(vm);
    end
end

function intcodeJumpIfTrue(vm::VM, parameters, modes)
    return intcodeJump(vm, parameters, modalize, x -> x != 0)
end

function intcodeJumpIfFalse(vm::VM, parameters, modes)
    return intcodeJump(vm, parameters, modalize, x -> x == 0)
end

function intcodeCompare(vm::VM, parameters, modes, compare::Function)
    (left, right) = modalize(vm, parameters, modes)
    intcode_write(vm, parameters[3] + 1, Int(compare(left, right)))
    return nextInstruction(vm)
end

function intcodeLessThan(vm::VM, parameters, modes)
    return intcodeCompare(vm, parameters, modes, <)
end

function intcodeEquals(vm::VM, parameters, modes)
    return intcodeCompare(vm, parameters, modes, ==)
end

function intcodeExit(vm::VM, parameters, modes)
    throw(Exception("The main loop should never have sent us to the exit function."))
end

function nextInstruction(vm::VM)
    return vm.inst_ptr + intcode[vm.code[vm.inst_ptr] % 100].n
end

const intcode = Dict([
    (1, (f=intcodeAdd, n=4, name="Add")),
    (2, (f=intcodeMultiply, n=4, name="Multiply")),
    (3, (f=intcodeInput, n=2, name="Input")),
    (4, (f=intcodeOutput, n=2, name="Output")),
    (5, (f=intcodeJumpIfTrue, n=3, name="Jump-if-true")),
    (6, (f=intcodeJumpIfFalse, n=3, name="Jump-if-false")),
    (7, (f=intcodeLessThan, n=4, name="Less than")),
    (8, (f=intcodeEquals, n=4, name="Equals")),
    (99, (f=intcodeExit, n=1, name="Exit"))
]);


function run(code::Array{Int,1}; inputs::Array{Int,1}=Array{Int,1}(undef,0), in::IO=stdin, out::IO=stdout)
    vm = VM(copy(code), inputs, Array{Int,1}(undef,0), 1, in, out)
    while (inst::Int = vm.code[vm.inst_ptr]) != 99
        opcode = inst % 100;
        parameters = view(vm.code, (vm.inst_ptr + 1):(vm.inst_ptr + intcode[opcode].n - 1));
        modes = ((inst ÷ 100) % 10,
            (inst ÷ 1000) % 10,
            (inst ÷ 10000) % 10);
        vm.inst_ptr = intcode[opcode].f(vm, parameters, modes);
    end
    return (vm.code,vm.outputs)
end

export run

end # module
