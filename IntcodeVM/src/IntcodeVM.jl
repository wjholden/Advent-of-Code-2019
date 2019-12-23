module IntcodeVM

# See https://www.reddit.com/r/adventofcode/comments/ebp057/what_does_everyones_intcode_interface_look_like/fb7awoy/
# for a description of this program's usage.

using Sockets
using DelimitedFiles

mutable struct VM
    code::Array{Int,1}
    inputs::Array{Int,1}
    outputs::Array{Int,1}
    inst_ptr::Int
    input::IO
    output::IO
    relative_base::Int
end

struct Instruction
    f::Function
    n::Int
end

function intcode_check_bounds(vm::VM, i::Int)
    if i > length(vm.code)
        z = zeros(i - length(vm.code))
        vm.code = vcat(vm.code, z)
    end
end

function intcode_parameter(vm::VM, i::Int, setter::Bool=false)
    parameter = vm.code[vm.inst_ptr + i];
    mode = (vm.code[vm.inst_ptr] ÷ (10^(1+i))) % 10;

    if setter
        # From https://adventofcode.com/2019/day/5:
        # "Parameters that an instruction writes to will never be in immediate mode."
        if mode == 1
            throw(Exception("Unexpected immediate mode setter"))
        end
        return parameter + 1 + (mode == 2 ? vm.relative_base : 0)
    else
        if mode == 0                # position
            intcode_check_bounds(vm, parameter + 1)
            return vm.code[parameter + 1];
        elseif mode == 1            # immediate
            return parameter;
        elseif mode == 2            # relative
            intcode_check_bounds(vm, parameter + 1 + vm.relative_base)
            return vm.code[parameter + 1 + vm.relative_base]
        end
    end
end

function intcode_parameters(vm::VM, r::UnitRange{Int})
    return [intcode_parameter(vm, i) for i in r]
end

function intcode_write(vm::VM, dst::Int, value::Int)
    intcode_check_bounds(vm, dst)
    vm.code[dst] = value
end

function intcode_ternary_op(vm::VM, f::Function)
    left, right = intcode_parameters(vm, 1:2)
    dst = intcode_parameter(vm, 3, true)
    intcode_write(vm, dst, f(left, right))
    return nextInstruction(vm);
end

function intcodeAdd(vm::VM)
    return intcode_ternary_op(vm, +)
end

function intcodeMultiply(vm::VM)
    return intcode_ternary_op(vm, *)
end

function intcodeInput(vm::VM)
    dst = intcode_parameter(vm, 1, true);
    # If the "inputs" array contains something, take it. Otherwise, read real IO.
    if isempty(vm.inputs)
        value_read = parse(Int, readline(vm.input))
        intcode_write(vm, dst, value_read)
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
    left, right = intcode_parameters(vm, 1:2)
    if condition(left)
        return right + 1
    else
        return nextInstruction(vm);
    end
end

function intcodeJumpIfTrue(vm::VM)
    return intcodeJump(vm, !=(0))
end

function intcodeJumpIfFalse(vm::VM)
    return intcodeJump(vm, ==(0))
end

function intcode_comparison(vm::VM, compare::Function)
    left, right = intcode_parameters(vm, 1:2)
    dst = intcode_parameter(vm, 3, true);
    intcode_write(vm, dst, Int(compare(left, right)))
    return nextInstruction(vm)
end

function intcodeLessThan(vm::VM)
    return intcode_comparison(vm, <)
end

function intcodeEquals(vm::VM)
    return intcode_comparison(vm, ==)
end

function intcodeExit(vm::VM)
    error("The main loop should never have sent us to the exit function.")
end

function nextInstruction(vm::VM)
    return vm.inst_ptr + intcode[vm.code[vm.inst_ptr] % 100].n
end

function intcode_dump_instruction(vm::VM)
    println(stderr, view(vm.code, vm.inst_ptr:(vm.inst_ptr + (intcode[vm.code[vm.inst_ptr] % 100].n) - 1)))
end

function intcode_set_relative_base_offset(vm::VM)
    vm.relative_base += intcode_parameter(vm, 1)
    return nextInstruction(vm)
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

function compareMemory(ref::Array{Int,1}, diff::Array{Int,1})
    if length(ref) != length(diff)
        println("Length of memory has changed from $(length(ref)) to $(length(diff))")
    end
    for i in 1:length(diff)
        if get(ref,i,0) != diff[i]
            println("vm[$(i-1)] $(get(ref,i,0)) -> $(diff[i])")
        end
    end
end

function run(code::Array{Int,1}; inputs::Array{Int,1}=zeros(Int,0), in::IO=devnull, out::IO=devnull, dump_instruction::Bool=false, dump_code::Bool=false)
    vm = VM(copy(code), inputs, Array{Int,1}(undef,0), 1, in, out, 0)
    ref = copy(code)
    while (inst::Int = vm.code[vm.inst_ptr]) != 99
        opcode = inst % 100;
        if dump_code
            println(compareMemory(ref, vm.code))
            ref = copy(vm.code)
        end
        if dump_instruction intcode_dump_instruction(vm) end
        vm.inst_ptr = intcode[opcode].f(vm);
    end
    return (vm.code,vm.outputs)
end

function run_async(filename::String, port::Int=60000)
    run_async(load_intcode(filename), port)
end

function run_async(code::Array{Int,1}, port::Int=60000)
    @async begin
        vm_listener = listen(port)
        vm_socket = accept(vm_listener)
        IntcodeVM.run(code, in=vm_socket, out=vm_socket)
        close(vm_socket)
        close(vm_listener)
    end
end

function run_sync(filename::String)
    return IntcodeVM.run(load_intcode(filename), in=stdin, out=stdout)
end

function load_intcode(filename::String)
    code = vec(readdlm(filename, ',', Int, '\n'))
end

export run, run_async, run_sync, load_intcode

end # module