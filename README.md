# 3D Brownian Diffusion Pipeline & V&V Framework

This repository contains a multi-threaded Julia engine that simulates 3D stochastic Brownian molecular diffusion subjected to external aerodynamic wind drift. 

Instead of traditional unit testing, this project implements a rigorous Verification & Validation (V&V) automation framework to mathematically audit the integrity of the stochastic simulation against established physics laws.

## 📊 Simulation Preview
![3D Molecular Cloud Expansion](report/images/diffusion_3d_demo1.gif)
![3D Molecular Cloud Expansion with Wind Drift](report/images/diffusion_3d_demo2.gif)

## 🛠️ Architecture & Core Dependencies
* **Core Engine:** Julia 1.10+ (leveraging native multi-threading for particle step updates)
* **Graphics:** CairoMakie.jl (used for vector-rendered data visualization)
* **CLI Interface:** ArgParse.jl (type-safe boundary input management)

## 🧬 The V&V Testing Strategy (`test/runtests.jl`)
Testing a stochastic Monte Carlo model requires statistical assertions rather than static expected outputs. Our pipeline executes three specific validation gates:

1. **Numerical Sanity:** Catches matrix dimension mismatches and actively scans arrays to ensure no floating-point operations return `NaN` or `Inf`.
2. **Kinematic Bounds:** Verifies all particle vectors strictly initiate at the origin $(0,0,0)$ and that consecutive spatial step delta limits are physically constrained.
3. **Statistical Invariance:** 
   * **Spatial Isotropy:** Confirms uniform multi-axis thermal dispersion remains within a strict 15% variance ceiling.
   * **Analytical Convergence:** Dynamically cross-references empirical simulation outputs against the core Mean Squared Displacement (MSD) textbook solution:
     $$MSD = 2dDt + (v_{wind} \cdot t)^2$$
     If empirical data drifts past the analytical threshold, the pipeline automatically aborts the image rendering stage to prevent corrupted visual reports.

## 🚀 Execution Guide
The engine functions as a decoupled CLI tool. You can pass arbitrary parameters or batch-loop scenarios via the shell wrapper.

```bash
# Setup
git clone git@github.com:PGComplexSystems/3dDiffusion.git
cd 3dDiffusion

# Syntax: ./run_pipeline.sh <STEPS> <PARTICLES> <WIND_SPEED>
./run_pipeline.sh 1600 300 2.5
```

## 📈 Planned System Updates
* [ ] Shift runtime arguments to a standalone `config.toml` parser.
* [ ] Dynamically bake input metrics directly into CairoMakie plot headers.
* [ ] Set up a GitHub Actions workflow to run the V&V suite on push events.
