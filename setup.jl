using Pkg

println("[0/3 Setup] Activating project environment...")
Pkg.activate(@__DIR__)

println("[0/3 Setup] Checking and installing missing dependencies...")
# Check and add CairoMakie
if !haskey(Pkg.project().dependencies, "CairoMakie")
    Pkg.add("CairoMakie")
end

# Check and add ProgressMeter
if !haskey(Pkg.project().dependencies, "ProgressMeter")
    Pkg.add("ProgressMeter")
end

if !haskey(Pkg.project().dependencies, "ArgParse")
    Pkg.add("ArgParse")
end

# Ensure all other dependencies in the Manifest are safely downloaded
Pkg.instantiate()

println("[0/3 Setup] Pre-compiling packages for fast execution...")
Pkg.precompile()

println("[0/3 Setup] Ready! All packages are installed and verified.")
