using DelimitedFiles

input = readdlm("input.txt",' ',Int,'\n')

# Part 1
fuel_required(mass) = (mass ÷ 3) - 2
part1 = reduce(+, map(fuel_required, input))
println("Part 1: ", part1)

# Part 2
fuel_required_2(mass) = (fuel_required(mass) > 0) ? fuel_required(mass) + fuel_required_2(fuel_required(mass)) : 0
part2 = reduce(+, map(fuel_required_2, input))

println("Part 2: ", part2)
