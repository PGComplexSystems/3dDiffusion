using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))

using ArgParse  # NEW: Native CLI Package
using Random
using Serialization
using Base.Threads

# Define the formal CLI schema interface
function parse_commandline()
    s = ArgParseSettings(description = "Parallel 3D Wind-Drift Diffusion Engine.")

    @add_arg_table! s begin
        "--steps"
            help = "Number of timeline steps to calculate"
            arg_type = Int
            default = 400
        "--particles"
            help = "Number of stochastic particles to track"
            arg_type = Int
            default = 300
        "--wind"
            help = "Constant drift velocity force along the X-axis"
            arg_type = Float64
            default = 1.5
    end

    return parse_args(s)
end

# Extract type-safe parameters cleanly
parsed_args = parse_commandline()
num_steps     = parsed_args["steps"]
num_particles = parsed_args["particles"]
wind_speed_x  = parsed_args["wind"]

println("[1/3 Simulation] Initializing 3D Parallel Engine...")
println("Configuration: Steps=$num_steps | Particles=$num_particles | Wind=$wind_speed_x")

# --- (The remaining physics simulation logic stays exactly identical) ---
dims = 3                    
const dt = 0.005             
const D = 1.2               

metadata = Dict("dt" => dt, "D" => D, "wind_speed_x" => wind_speed_x)
results = Array{Float64, 3}(undef, num_steps, num_particles, dims)
time_steps = collect(1:num_steps) .* dt

Threads.@threads for p in 1:num_particles
    rng = Random.MersenneTwister(42 + p)
    noise_scale = sqrt(2.0 * D * dt)
    
    kicks_x = [0.0; noise_scale .* randn(rng, num_steps - 1)]
    kicks_y = [0.0; noise_scale .* randn(rng, num_steps - 1)]
    kicks_z = [0.0; noise_scale .* randn(rng, num_steps - 1)]
    
    for t in 2:num_steps
        kicks_x[t] += wind_speed_x * dt
    end
    
    results[:, p, 1] = cumsum(kicks_x)
    results[:, p, 2] = cumsum(kicks_y)
    results[:, p, 3] = cumsum(kicks_z)
end

cache_path = joinpath(@__DIR__, "..", "report", "images", "sim_3d_data.jls")
open(cache_path, "w") do io
    serialize(io, (time_steps, results, metadata))
end
println("[1/3 Simulation] Complete. Physics data cached.")
