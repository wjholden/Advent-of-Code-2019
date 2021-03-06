using DelimitedFiles

input = readdlm(ARGS[1], ' ', Int, '\n');

# Part 1
fuel_required(mass) = (mass ÷ 3) - 2;
part1 = reduce(+, map(fuel_required, input))
println("Part 1: ", part1)

# Part 2
function fuel_required_2(mass)
    fuel = fuel_required(mass)
    return (fuel > 0) ? fuel + fuel_required_2(fuel) : 0;
end
part2 = reduce(+, map(fuel_required_2, input))
println("Part 2: ", part2)

# Nothing too crazy here for those familiar with recursion, although reading the instructions carefully always helps.
# Notice something interesting: the part 2 function does not distribute. That is, you cannot compute
#   fuel_required_2(part1) + part1
# to get part2. 
# https://twitter.com/wjholdentech/status/1201023263633219585
