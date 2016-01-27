# Mixed-integer optimization

## Preassignment

For this class, we will be using the Gurobi mixed-integer programming solver. 

### Installing Gurobi
Gurobi is commercial software, but they have a very permissive (and free!) academic license. If you have an older version of Gurobi (>= 5.5) on your computer, that should be fine.

1. Go to www.gurobi.com
2. Create an account, and request an academic license.
3. Download the installer for Gurobi 6.5
4. Install Gurobi, accepting default options. Remember where it installed to!
5. Go back to the website and navigate to the page for your academic license. You'll be given a command with a big code in it, e.g. grbgetkey aaaaa-bbbb
6. In a terminal, navigate to the ``gurobi650/<operating system>/bin`` folder where ``<operating system>`` is the name of your operating system.  
7. Copy-and-paste the command from the website into the command prompt---you need to be on campus for this to work!


### Install the Gurobi interface in Julia

Installing this is easy using the Julia package manager: 
```jl
julia> Pkg.add("Gurobi")
```

If you don't have an academic email or cannot get access for Gurobi for another reason, you should be able to follow along with the open source solver GLPK for much of the class. To install, simply do
```jl
julia> Pkg.add("GLPKMathProgInterface")
```

## Other packages
Also install the other packages we will need for class:
```jl
Pkg.add(“Interact”)
Pkg.add(“Gadfly”)
Pkg.add(“Compose”)
```

## Solving a simple MIP
How about a simple knapsack problem? Enter the following JuMP code and submit all the output to Stellar.

```jl
using JuMP, Gurobi
m = Model(solver=GurobiSolver(Presolve=0)) # turn presolve off to make it a lil more interesting
N = 100
@defVar(m, x[1:N], Bin)
@addConstraint(m, dot(rand(N), x) <= 5)
@setObjective(m, Max, dot(rand(N), x))
solve(m)
```

## Questions?
Email huchette@mit.edu
