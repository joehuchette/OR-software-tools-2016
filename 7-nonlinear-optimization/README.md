# Nonlinear optimization

This class will cover computational aspects of **convex and nonlinear optimization**,
drawing from motivating examples in statistical regression and machine learning models. Please follow the installation instructions below before the class. The preassignment
at the end is a check that everything is installed correctly.

## Install Julia

We require Julia 0.4.0 or later. **If you have an older version of Julia installed, e.g., 0.3 or 0.4.0-rc1, please update to the latest version**.
Binaries of Julia for all platforms are available [here](http://julialang.org/downloads/).

- Windows and Linux users should choose the 64-bit version, unless using a very old computer.

If updating from Julia 0.4.0-rc1, you should also update your packages by running:

```julia
Pkg.update()
```

from a Julia prompt.

## Install IJulia/Jupyter

Follow the instructions [here](https://github.com/stevengj/julia-mit#installing-julia-and-ijulia) to set up IJulia.
If you've used IJulia previously and just updated Julia, double check that IJulia is still working!
If you haven't used IJulia but attended the previous class, you should already be familiar with the interface!

## Install Gurobi

Gurobi is a commercial mixed integer linear and mixed integer second-order conic solver which
we will be using during the class. If you don't have Gurobi installed already, please follow their
[installation guide](http://www.gurobi.com/documentation/) for your platform.

The main steps (thanks to Jack Dunn) are:

- Go to [gurobi.com](http://www.gurobi.com) and sign up for an account
- Get an academic license from the website (section 2.1 of the quick-start guide)
- Download and install the Gurobi optimizer (section 3 of the quick-start guide)
- Activate your academic license (section 4.1 of the quick-start guide)
  * you need to do the activation step while connected to the MIT network. If you are off-campus, you can use the [MIT VPN](https://ist.mit.edu/vpn) to connect to the network and then activate (get in touch if you have trouble with this).
- Test your license (section 4.6 of the quick-start guide)

## Install Julia packages

We will use (some of) the following packages:
- Convex
- JuMP
- Optim
- Ipopt
- Distributions
- Gadfly
- PyPlot
- Interact
- Gurobi
- ECOS

Install each one by running ``Pkg.add("xxx")`` where ``xxx`` is the package name
from a Julia prompt or notebook.

## Preassignment

In a blank IJulia notebook, paste the following code into a cell:

```julia
using Convex
using Gurobi
x = Variable(Positive())
solve!(minimize(x), GurobiSolver())
evaluate(x)
```

The result should be some iteration output from Gurobi and then
the value zero.

If you have some free time, look at [dcp.stanford.edu](http://dcp.stanford.edu/home) and play the [DCP quiz](http://dcp.stanford.edu/quiz). As part of the class, we will learn how to solve convex nonlinear optimization problems by writing them down in DCP form.
