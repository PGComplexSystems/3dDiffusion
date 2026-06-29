using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))

using Test
using Serialization
using LinearAlgebra
using Statistics

println("==========================================")
println(" RUNNING DYNAMIC WIND-DRIFT TEST SUITE     ")
println("==========================================")

# 1. Load data safely from pipeline cache
cache_path = joinpath(@__DIR__, "..", "report", "images", "sim_3d_data.jls")
if !isfile(cache_path)
    error("CRITICAL TEST FAILURE: Simulation cache file missing.")
end
time_steps, results, metadata = open(deserialize, cache_path)

num_steps, num_particles, dims = size(results)

# 2. Extract physics parameters dynamically from metadata
dt = metadata["dt"]
D = metadata["D"]
v_wind_x = metadata["wind_speed_x"]

@testset "1. Matrix Structure & Memory Safety" begin
    @test dims == 3
    @test num_steps > 0
    @test num_particles > 0
    @test all(isfinite.(results))
end

@testset "2. Physical Conservation & Boundary Laws" begin
    # Initial State Validation (All particles must start at origin)
    @test all(results[1, :, :] .== 0.0)
    
    # Kinematic Velocity Bound Check:
    # Must account for the maximum random jump plus the directional wind drift displacement
    σ_noise = sqrt(2.0 * D * dt)
    max_step_delta = maximum(abs.(diff(results, dims=1)))
    drift_per_step = abs(v_wind_x * dt)
    
    @test max_step_delta < (6.5 * σ_noise + drift_per_step)
end

@testset "3. Stochastic Ensemble & Analytical Validation" begin
    # Target 1: Spatial Isotropy (Random spread rate should still be uniform)
    var_x = var(results[end, :, 1])
    var_y = var(results[end, :, 2])
    var_z = var(results[end, :, 3])
    mean_var = mean([var_x, var_y, var_z])
    
    @test abs(var_x - mean_var) / mean_var < 0.15
    @test abs(var_y - mean_var) / mean_var < 0.15
    @test abs(var_z - mean_var) / mean_var < 0.15

    # Target 2: Dynamic Center Shift Check (The cloud center must track the wind profile)
    final_time = time_steps[end]
    expected_center_x = v_wind_x * final_time
    calculated_center_x = mean(results[end, :, 1])
    
    println("--> Expected Center X (Wind-Driven): $(round(expected_center_x, digits=2))m")
    println("--> Empirical Center X (Simulated):   $(round(calculated_center_x, digits=2))m")
    
    # Check if X-center matches wind physics within a reasonable tolerance margin
    @test abs(calculated_center_x - expected_center_x) < 1.0
    
    # Y and Z centers are unaffected by wind and should hover close to 0.0
    @test abs(mean(results[end, :, 2])) < 1.0
    @test abs(mean(results[end, :, 3])) < 1.0

    # Target 3: Mean Squared Displacement (MSD) Analytical Match
    # Corrected for uniform drift velocity: MSD_drift = 2dDt + (v*t)^2
    analytical_msd = (2.0 * dims * D * final_time) + (expected_center_x^2)
    calculated_msd = mean([norm(results[end, p, :])^2 for p in 1:num_particles])
    
    percentage_error = abs(calculated_msd - analytical_msd) / analytical_msd
    println("--> Empirical MSD:  $(round(calculated_msd, digits=2))")
    println("--> Analytical MSD: $(round(analytical_msd, digits=2))")
    println("--> Deviation:      $(round(percentage_error * 100, digits=2))%")
    
    @test percentage_error < 0.15
end

println("==========================================")
