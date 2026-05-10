
# DLSS in Blender is AWESOME

Once I knew DLSS works in blender I got super obsessed with it. 

* **It's a superfast cycles denoiser**, but it only works on NVIDIA cards, and has to be built manually. 
* You can check out [Polyfjord video](https://www.youtube.com/watch?v=iBiSKfjTNDY&t=2s) to see what it is.

It's super cool, and it works on **Linux.** Please help me make it work on ***NixOS**.*

> I'm too dumb to Nixifying it 🤓
![alt text|363](https://github.com/NotAvari/Nixos-Blender-DLSS-Overlay/blob/main/imgs/stupid_kiddo.png?raw=true)

# You could help or just read 'my' guide and build blender with DLSS for yourself!

## Guide reference

You can look at [DLSS Build Kinda Guide.md](https://github.com/NotAvari/Nixos-Blender-DLSS-Overlay/blob/main/DLSS%20Build%20Kinda%20Guide.md "DLSS Build Kinda Guide.md") file to see how I built it on arch (btw). 
I did it recently in arch distrobox, and it still works.
I followed Windows guide and adapted it for Linux (it was pretty straightforward)
## Nix `overlay` file

I tried to overlay the blender package from nixpkgs to make the thing. You can find it in repo files or [here](https://github.com/NotAvari/Nixos-Blender-DLSS-Overlay/blob/main/blender-dlss.nix)

**My blender is PINNED**, use this rev or pin it as well - `b6c718eef59f07c8179560c9dcb29715cdf3bf4e`

# The problem

The thing actually builds and you even get to choose DLLS as your Denoiser. 

![alt text|847](https://github.com/NotAvari/Nixos-Blender-DLSS-Overlay/blob/main/img/denoiser.png?raw=true)

>But it doesn't work. I couldn't pinpoint the issue because I'm too dumb

Everything relies heavily on `dlss.so` files that I place in the **same folder** where blender binary is.
I know that most stuff should be done with `RPATH`, so I just copied `RPATH` from `.blender-wrapped` file to `dlss.so`, but it didn't help.

# Let's make it work for everyone with the power of Nix!
## (yeah I'm cringe so what)

![alt text|751](https://github.com/NotAvari/Nixos-Blender-DLSS-Overlay/blob/main/imgs/iq_too_low.png?raw=true)
