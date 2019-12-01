using DelimitedFiles

# Part 1
fuel_required(mass) = (mass ÷ 3) - 2
part1 = reduce(+, map(fuel_required, readdlm("input.txt",' ',Int,'\n')))

# Part 2
fuel_required_2(mass) = (fuel_required(mass) > 0) ? fuel_required(mass) + fuel_required_2(fuel_required(mass)) : 0
part2 = reduce(+, map(fuel_required_2, readdlm("input.txt",' ',Int,'\n')))

println("Part 1: ", part1)
println("Part 2: ", part2)
