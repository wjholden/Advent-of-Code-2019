# Advent of Code 2019
This is my third year participating in [Advent of Code](https://adventofcode.com/2019). I look forward to this all year. Last year I tried *[Mathematica](https://wjholden.com/aoc/2018/)* and it was a great experience. This year: [Julia](https://julialang.org/)!

Advent of Code is a wonderful way for experienced programmers to practice a new language. The challenges get extremely difficult. The complexity and variety of the challenges will stress test any programming language, showing you where the language (and the programmer) are weak and strong.

I *loved* the **Intcode** problems this year! This month of programming puzzles required most of what learned in my computer science degree *and more*.

Below are my impression of the major theme for each day.

# Daily Themes and Stars
1. `**` Loops, functions, and recursion (`map`/`reduce`)
2. `**` Assembly language basics
3. `**` Procedural programming, Cartesian space, complex arithmetic
4. `**` Conditions (`filter`)
5. `**` Assembly language jumps and conditions
6. `**` Basic graphs, Dijkstra's algorithm
7. `**` Concurrency, pipelining, encapsulation
8. `**` Image processing, multidimensional arrays
9. `**` Software engineering, testing and verification
10. `**` Number theory or floating point arithmetic, sorting and searching
11. 
12. `**` Attractors, number theory, large problems
13. `**` Games, reverse engineering
14. 
15. `**` Depth-first search
16. `* ` Signal processing
17. `* ` ASCII, scripting (meta-metaprogramming with Intcode!)
18. 
19. `**` Linear programming, dynamic programming, quadratic complexity
20. `* ` Dijkstra's algorithm
21. 
22. `* ` Circular arrays, uhhh...
23. `**` Networking, concurrency
24. `* ` Automata, binary tricks (`fold`/`nest`), recursion, whoa...
25. 

# Hotwash
## Environment
This year I set out to practice Julia. I did not bother with Jupyter notebooks at all. Rather, I did all of my work in [Visual Studio Code](https://code.visualstudio.com/) and in Julia's REPL.

I experimented with Microsoft's new [Windows Terminal](https://github.com/microsoft/terminal). It's OK, but I found it kind of slow and the scrollbar does not always work.

Julia's REPL is a joy to work in. Emacs-style keyboard shortcuts work. The built-in help (`?`) is useful. I can paste in half of my program and take a close look at what is going on.

I used [GitHub Desktop](https://desktop.github.com/) to publish my programs. Someday I will get around to getting good at `git`, but for now this is good enough.

There was one program that I reduced to my own [JavaScript Dijkstra solver](https://wjholden.com/dijkstra). Since then I have found the very robust [LightGraphs](https://juliagraphs.github.io/LightGraphs.jl/latest/) library.

There was also one puzzle where I used Java for an [interactive GUI](https://www.youtube.com/watch?v=9d_-wP1aQCo). Julia could have done this, but I have no motivation to learn another windowing toolkit.

## General Julia Observations
Much of what I learned this year were basics and tricks of the Julia language. Most of my programming experience is in Java, JavaScript, and *Mathematica*. My *Mathematica* adventure last year influenced my thought process than I realized. I eagerly reach for `filter`, `map`, and `reduce` when possible. I use lots of tuples and matrices. Functions would compose nicely in *Mathematica* and they compose equally well in Julia.

Things I really *do not* miss from *Mathematica* was the ugly double brackets for array indices (`x[[1]]`), anonymous function arguments (`#` and `#1, #2, ...`), ampersand notation (`&`) to denote pure functions, unweildy `Module` syntax and scoping, and poor performance. *Mathematica's* symbolic computation is very powerful but can be challenging to newcomers. I don't think I ever really felt like an Advent of Code problem could be better solved with symbolic computation.

The big things I did miss from *Mathematica* were the `Nest` statement (to compute `f ∘ f ∘ ... ∘ f(x)`) and the beautiful visualizations. Julia has a [Plots](http://docs.juliaplots.org/latest/) package that I used a few times, but not as easily or frequently as last year. It might have made a difference if I had recently taken a math class using Julia.

Julia is extremely expressive. I love the syntax. I frequently thought about how tedious some of these programs would have been if I were still using Java. 

Julia is fast. I threw an 800×800ish matrix at a cubic time algorithm. Program completes in about four seconds. It's beautiful!

Julia does take second to "warm up." I assume this is all JIT. My day 7 solution (which I started to improve but did not finish) required 600 different Julia processes. Even on a modern computer, these processes require many minutes.

Julia does not have as rich a library as older and more popular languages (C++, Java, Python) but it has a modest and growing ecosystem. The modules I used were OffsetArrays, Sockets, LightGraphs, Combinatorics (`permutations`), DelimitedFiles, Memoize, and LinearAlgebra (`norm`).

Strong typing saved me a few times.

List comprehension is very powerful (example: `[4 * row + col for row=0:5, col=1:4]`). I had encountered [list comprehension in Python](https://www.artima.com/weblogs/viewpost.jsp?thread=98196) before, but it was not familiar enough to come to my mind quickly when solving puzzles. List comprehension is basically the same thing as *Mathematica's* `Array` function.

I think I only defined a `struct` once. The only module that I needed was to make my Intcode VM reusable. I did not learn Julia's exception handling mechanisms. I poked my little toe into Julia's concurrency and networking functions but I still have a lot to learn.

## Specific Julia Lessons Learned
These are specific elements of the Julia language that I found particularly interesting or useful. I recommend reading [The Julia Express](https://github.com/bkamins/The-Julia-Express) if you are an experienced programmer intersted in getting started in Julia quickly.

1. Occasionally I would miss Java/C-style `if (condition) statement;` one-liners. You can do this in Julia, but you still need the `end` keyword at the end, such as `if condition statement end`. I looks kind of strange, and there is a very nice alternative: `condition && statement`!
2. `count(p, a)` is the same thing as `length(filter(p, a))`.
3. `findfirst(p, a)` takes a predicate function, such as `findfirst(<=(0.1), rand(5, 5))`. (Related: `<=(0.1)` is a nice shorthand for the lambda `x -> x <= 0.1`). This is in contrast to `searchsortedfirst(a, v)` which takes a value, such as `searchsorted(sort(rand(100)), 0.8)`.
4. `0 + Inf` throws an error. `0.0 + Inf` does not.
5. List comprehension is really the same thing as `map`.
6. The range operator (`:`) is very useful. If strongly typed functions will not accept a `Range`, then you can effortlessly convert a range to an array with `collect`.
7. Default parameter values can be specified in the function signature. `function f(x=10)` does exactly what you expect.
8. A `struct` is basically the same thing as a named tuple, but you can mark them `mutable` and a `struct` is easier to specify for strongly-typed functions.
9. Optional type annotations are wonderful. I really did feel like I was getting the performance of Java with the expressiveness of Python.
10. Tuples are basically the same thing as arrays. They're wonderful! I frequently return two values from a function in Julia, thinking back to the bad old days where this was really inconvenient in Java and C.
11. The Plots package is very easy to use.
12. So is LightGraphs.
13. The `global` keyword is mildly annoying. I think Python has similar syntax, semantics, and structure. The thing that really surprised me is that you have to specify `global` inside a loop, even if that loop was not part of a function. You do not need the `global` keyword for structure or array members.
14. "`map` is not defined on sets." I guess this makes sense now that I think about it. It seems strange to get an array of arbitrary elements from a set of distinct elements. If you really want to use `map` over a `Set` then you can `collect` the set first.
15. You *can* use `for` and `foreach` with `Set` and `Dict`. The values in a dictionary are passed as a `Pair`, which you can access by index (1 and 2) or with `first` and `last`.
16. One-indexed arrays (values start at `a[1]` instead of `a[0]`) are often annoying. You can redefine your arrays with arbitrary dimensions using the OffsetArrays module. I did not find that this module is very well-documented. If you have a 50-element array `a` and want to access it with indices starting from 0, simply enter `a = OffsetArray(a, 0:49)`.
17. The `get` function is a nice way to give a default value for values not found in a data structure. The documentation shows this used for dictionaries but `get` can also work with arrays. For example, `get(rand(3), 4, -1)` (there is no position 4, so return -1).
18. `elseif` took me a while to get used to.
19. I miss the `switch` statement. While I can understand why no one wants to repeat the disastrous experience C gave us (see [Gustavo Silva on -Wimplicit-fallthrough in Linux](https://twitter.com/embeddedgus/status/1155206150104801282)), I really liked the sensible `switch` statement from *Mathematica* and Excel.
20. You can accidentally overwrite reserved function names. Once, I used the word `values` for a variable, which gave a crazy error message when I tried to invoke the `values` function on a dictionary. This made me more cautious about naming things than I ever needed to be in Java.
21. Vectorized functions are awesome! Just prefix any function with a `.` to apply that function element-wise to each member of an array. For example, to take the root of every member in a list you can enter `sqrt.(rand(8,4))`. This also works for binary operators, but for some reason you have to put the period first. For example, `17 .* rand(8,4)`. You can even use the "dot" syntax with *n*-ary functions, such as `string.(rand(0:0xffffffff, 12), base=16, pad=8)`. Maybe this is just a shorthand for `map`, but I still found it very convenient.
22. `NaN != NaN` is *true*, as it is in other languages. Julia has some nice helper functions like `isfinite`, `isnan`, etc. Just type `is` into the REPL and press tab twice.
23. Julia's `Sockets` library was very easy to use. The only language where I have any real networking experience to speak of is Java. Java's sockets are also easy to use, but they require lots of boilerplate code that you can (perhaps not safely...) ignore in Julia.
