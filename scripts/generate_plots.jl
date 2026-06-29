using Pkg
Pkg.activate(joinpath(@__DIR__, ".."))

using CairoMakie
using Serialization
using LinearAlgebra
using ProgressMeter
using Statistics

println("[2/3 Plotting] Loading 3D dataset...")
cache_path = joinpath(@__DIR__, "..", "report", "images", "sim_3d_data.jls")
if !isfile(cache_path)
    error("3D Data missing! Run simulation script first.")
end
time_steps, results = open(deserialize, cache_path)

num_steps, num_particles, _ = size(results)

# Clean out outlier positions for a focused frame zoom
max_val = quantile(vec(abs.(results)), 0.97)
axis_limits = (-max_val, max_val, -max_val, max_val, -max_val, max_val)

println("[2/3 Plotting] Initiating Makie Cinematic Dark-Theme Render...")

# Set up the Observables
points = Observable(Point3f.(results[1, :, 1], results[1, :, 2], results[1, :, 3]))
colors = Observable(zeros(num_particles))

# FIX 1: Set figure background to a clean, dark slate black
fig = Figure(resolution = (1000, 1000), figure_padding = 0, backgroundcolor = "#0B0C10")

# FIX 2: Modernize the 3D grid layout with glowing dark properties
ax = Axis3(fig[1, 1], 
           title = "3D Molecular Cloud Expansion", 
           titlecolor = :white,
           xlabel = "X (m)", ylabel = "Y (m)", zlabel = "Z (m)",
           xlabelsize = 14, ylabelsize = 14, zlabelsize = 14,
           xlabelcolor = "#66FCF1", ylabelcolor = "#66FCF1", zlabelcolor = "#66FCF1", # Neon cyan axis text
           limits = axis_limits,
           aspect = :data,
           perspectiveness = 0.5,
           backgroundcolor = "#1F2833", # Darker container core
           xgridcolor = "#45A29E", ygridcolor = "#45A29E", zgridcolor = "#45A29E", # Subdued teal grid lines
           xticklabelcolor = :gray, yticklabelcolor = :gray, zticklabelcolor = :gray)

# FIX 3: Switched to ':inferno' colormap for an explosive hot neon core look
scatter!(ax, points, 
         color = colors, 
         colormap = :inferno, 
         markersize = 10, # Slightly increased for presence against black background
         alpha = 0.85)

println("[2/3 Plotting] Rendering dark-mode 3D frames into MP4...")

frame_range = 1:2:num_steps
pbar = Progress(length(frame_range), desc="Rendering Video: ", color=:cyan)

record(fig, joinpath(@__DIR__, "..", "report", "images", "diffusion_3d.mp4"), frame_range; fps = 30) do t
    points[] = Point3f.(results[t, :, 1], results[t, :, 2], results[t, :, 3])
    colors[] = [norm(results[t, p, :]) for p in 1:num_particles]
    ax.azimuth[] = 0.5 * (t * 0.002) # Keeps your newly updated smooth camera rotation
    next!(pbar)
end

println("[2/3 Plotting] Complete. Dark-theme presentation saved.")
