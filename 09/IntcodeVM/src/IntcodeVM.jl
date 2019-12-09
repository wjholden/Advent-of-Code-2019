module IntcodeVM

mutable struct VM
    code::Array{Int,1}
    inputs::Array{Int,1}
    outputs::Array{Int,1}
    inst_ptr::Int
    input::IO
    output::IO
    relative_base::Int
end

function intcode_check_bounds(vm::VM, i::Int)
    if i > length(vm.code)
        z = zeros(i - length(vm.code))
        vm.code = vcat(vm.code, z)
    end
end

function intcode_parameter(vm::VM, i::Int)
    parameter = vm.code[vm.inst_ptr + i];
    mode = (vm.code[vm.inst_ptr] ÷ (10^(1+i))) % 10;
    if mode == 1            # immediate
        return parameter;
    elseif mode == 0        # position
        intcode_check_bounds(vm, parameter + 1)
        return vm.code[parameter + 1];
    elseif mode == 2        # relative
        intcode_check_bounds(vm, parameter + 1 + vm.relative_base)
        return vm.code[parameter + 1 + vm.relative_base]
    end
end

function intcode_parameters(vm::VM, r::UnitRange{Int})
    return [intcode_parameter(vm, i) for i in r]
end

function intcode_write(vm::VM, dst::Int, value::Int)
    intcode_check_bounds(vm, dst)
    vm.code[dst] = value
end

function intcode3op(vm::VM, f::Function)
    (left, right) = intcode_parameters(vm, 1:2)
    # Parameters that an instruction writes to will never be in immediate mode.
    dst = vm.code[vm.inst_ptr + 3] + 1
    intcode_write(vm, dst, f(left, right))
    return nextInstruction(vm);
end

function intcodeAdd(vm::VM)
    return intcode3op(vm, +)
end

function intcodeMultiply(vm::VM)
    return intcode3op(vm, *)
end

function intcodeInput(vm::VM)
    dst = vm.code[vm.inst_ptr + 1] + 1
    # If the "inputs" array contains something, take it. Otherwise we can read from stdin.
    if isempty(vm.inputs)
        intcode_write(vm, dst, parse(Int, readline(vm.input)))
    else
        intcode_write(vm, dst, popfirst!(vm.inputs))
    end
    return nextInstruction(vm);
end

function intcodeOutput(vm::VM)
    left = intcode_parameter(vm, 1)
    println(vm.output, left)
    push!(vm.outputs, left)
    return nextInstruction(vm);
end

function intcodeJump(vm::VM, condition::Function)
    (left, right) = intcode_parameters(vm, 1:2)
    if condition(left)
        return right + 1
    else
        return nextInstruction(vm);
    end
end

function intcodeJumpIfTrue(vm::VM)
    return intcodeJump(vm, x -> x != 0)
end

function intcodeJumpIfFalse(vm::VM)
    return intcodeJump(vm, x -> x == 0)
end

function intcodeCompare(vm::VM, compare::Function)
    (left, right) = intcode_parameters(vm, 1:2)
    dst = vm.code[vm.inst_ptr + 3] + 1
    intcode_write(vm, dst, Int(compare(left, right)))
    return nextInstruction(vm)
end

function intcodeLessThan(vm::VM)
    return intcodeCompare(vm, <)
end

function intcodeEquals(vm::VM)
    return intcodeCompare(vm, ==)
end

function intcodeExit(vm::VM)
    throw(Exception("The main loop should never have sent us to the exit function."))
end

function nextInstruction(vm::VM)
    return vm.inst_ptr + intcode[vm.code[vm.inst_ptr] % 100].n
end

function intcode_dump_instruction(vm::VM)
    println(stderr, view(vm.code, vm.inst_ptr:(vm.instr_ptr + intcode[vm.code[inst_ptr] % 100])))
end

function intcode_set_relative_base_offset(vm::VM)
    vm.relative_base = intcode_parameter(vm, 1)
    return nextInstruction(vm)
end

struct Instruction
    f::Function
    n::Int
end

const intcode = Dict([
    (1, Instruction(intcodeAdd, 4)),
    (2, Instruction(intcodeMultiply, 4)),
    (3, Instruction(intcodeInput, 2)),
    (4, Instruction(intcodeOutput, 2)),
    (5, Instruction(intcodeJumpIfTrue, 3)),
    (6, Instruction(intcodeJumpIfFalse, 3)),
    (7, Instruction(intcodeLessThan, 4)),
    (8, Instruction(intcodeEquals, 4)),
    (9, Instruction(intcode_set_relative_base_offset, 2)),
    (99, Instruction(intcodeExit, 1))
]);


function run(code::Array{Int,1}; inputs::Array{Int,1}=Array{Int,1}(undef,0), in::IO=devnull, out::IO=devnull)
    vm = VM(copy(code), inputs, Array{Int,1}(undef,0), 1, in, out, 0)
    while (inst::Int = vm.code[vm.inst_ptr]) != 99
        opcode = inst % 100;
        vm.inst_ptr = intcode[opcode].f(vm);
    end
    return (vm.code,vm.outputs)
end

export run

end # module
