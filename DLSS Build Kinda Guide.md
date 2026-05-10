# Downloads
1. `sudo pacman -S cuda cmake ninja git-lfs`
2. [`Optix`](https://developer.nvidia.com/designworks/optix/download)
	1. `chmod +x ~/Downloads/NVIDIA-OptiX-SDK-9.1.0-linux64-x86_64.sh`
	2. `sudo mkdir -p /opt/optix`
	3. `sudo ./NVIDIA-OptiX-SDK-9.1.0-linux64-x86_64.sh --prefix=/opt/optix --exclude-subdir --skip-license`
3. [**Streamline SDK**](https://github.com/NVIDIA-RTX/Streamline/releases) (library files, I use 2.10.3)
4. [**DLSS Libraries**](https://github.com/NVIDIA/DLSS/tree/main/lib/Linux_x86_64/rel) (get all 3 `.so` files)
___
# Installation

Keep the [**windows guide**](https://www.reddit.com/r/blender/comments/1r1zoye/how_to_build_blender_with_dlss/) open for reference

## 1. Create a `Blender_DLSS` folder 
I put all necessary files in it. (*No spaces in folder name*)

```
mkdir ~/Blender_DLSS
cd ~/Blender_DLSS
```
## 2. Clone blender repo:

```
git clone https://projects.blender.org/pmoursnv/blender.git
```
## 3. Switch to DLSS branch:

```
git checkout dlss
```

**IMPORTANT** - I believe the DLSS driver check feature broke on Linux in the latest commits. (idk when exactly) 
You can use this rev - `ede17237ad8d472aa929f1d965740fb732e0eb61` or any earlier commit. I'm using this one - `7e9dab98484b8d9c87d95c18dde88967f33a530b`

## 3.1 
Run this command to install other building dependencies.
```
cd ~/Blender_DLSS/blender/
./build_files/build_environment/install_linux_packages.py
```
## 4. Edit configuration

`Blender DLSS/blender/build_files/cmake/config/blender_release.cmake`

Find `if(UNIX AND NOT APPLE)` and `if(NOT APPLE)` sections and add these lines to them 
*(just UNIX ANT NOT APPLE is enough I think)*
```
          #-------------------------------------------------------
  set(WITH_DLSS                   ON  CACHE BOOL "" FORCE)
  set(CYCLES_CUDA_BINARIES_ARCH   "sm_89" CACHE STRING "" FORCE)
```
* **sm_89** is for nvidia 40xx cards
* 30xx - sm_86;   40xx - sm_89; 50xx - sm_120
* Check the correct number [**here**](https://developer.nvidia.com/cuda/gpus) 

## Disable Inted/Amd stuff

Find and set these to **OFF**
```
    set(WITH_CYCLES_DEVICE_HIPRT    OFF CACHE BOOL "" FORCE)
    set(WITH_CYCLES_HIP_BINARIES    OFF CACHE BOOL "" FORCE)
    set(WITH_CYCLES_DEVICE_ONEAPI   OFF  CACHE BOOL "" FORCE)
    set(WITH_CYCLES_ONEAPI_BINARIES OFF  CACHE BOOL "" FORCE)
```

## 5. Set environment variables

**!!!** All `Env` variables have to be set each time you open terminal. They do not persist. **!!!**

```
export DLSS_SDK_ROOT="~/Blender_DLSS/Streamline_SDK/external/ngx-sdk" 
export OPTIX_ROOT_DIR="/opt/optix"
export CUDA_TOOLKIT_ROOT_DIR="/opt/cuda"
export CUDA_ROOT_DIR="/opt/cuda"
export PATH="/opt/cuda/bin:$PATH"
```

Check if everything worked 

```
echo "CUDA: $CUDA_TOOLKIT_ROOT_DIR"  
                                  ls -la "$CUDA_TOOLKIT_ROOT_DIR/bin/nvcc"  
                                  echo "OptiX: $OPTIX_ROOT_DIR"  
                                  ls -la "$OPTIX_ROOT_DIR/include/optix.h"  
                                  echo "DLSS: $DLSS_SDK_ROOT"  
                                  ls -la "$DLSS_SDK_ROOT/include/nvsdk_ngx_defs_dlssd.h"
```
___
## 6. Compile

==Super important== - otherwise you'll get a broken build
```
make update
```

**Now compile**
```
make release
```

Make sure everything is found at configuration step
![[Pasted image 20260219230643.png]]

### 6.1

### Hunting down compiler dependencies

I did it on arch and many of its libraries break the compilation process. Compiler errors will print out which version they expect. Just find which one you have and make a symlink with a correct name for it.

**Example:**
```
find /usr/lib -name "libIlmThread.so*"
```

### Symlinking to make it correct version

```
sudo ln -s /usr/lib/libIlmThread.so /usr/lib/libIlmThread.so.33
```

## 7. Copy DLSS `.so` libraries

![[Pasted image 20260219232107.png]]
Make all of them executable, copy and paste inside the `bin` folder inside `build_linux_release`



# Making `make` work on distrobox
```
PATH="/usr/bin:$PATH" make release
```
Otherwise it uses **host** libraries

## make `make update` work

```
export GIT_CONFIG_GLOBAL=/home/user/.gitconfig-writable
PATH="/usr/bin:$PATH" make update
```

## Vulkan error on NixOS host

```
sudo mkdir -p /usr/share/glvnd/egl_vendor.d 
```
``` 
sudo ln -sf /run/host/run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json /usr/share/glvnd/egl_vendor.d/10_nvidia.json
```

# It may be better to run it on Fedora (Arch is too much trouble)
idk man
