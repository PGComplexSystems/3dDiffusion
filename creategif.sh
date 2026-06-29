#!/bin/bash

ffmpeg -i report/images/diffusion_3d.mp4 -vf "fps=15,scale=480:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" report/images/diffusion_3d.gif
