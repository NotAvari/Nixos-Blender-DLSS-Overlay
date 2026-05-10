# pkgs/blender-dlss.nix
# My blender is pinned to this rev - b6c718eef59f07c8179560c9dcb29715cdf3bf4e
{
  lib,
  pkgs,
}: let
  dlssLibs = pkgs.fetchFromGitHub {
    owner = "NVIDIA";
    repo = "DLSS";
    rev = "982b0d19f9e35fef8e1b3109efa6b95470563866";
    hash = "sha256-9px3KFLiooqusF+NRsWnml7BvvrxzcpYUrUM2Gm0mxs=";
  };
  streamlineSdk = pkgs.fetchzip {
    url = "https://github.com/NVIDIA-RTX/Streamline/releases/download/v2.10.3/streamline-sdk-v2.10.3.zip";
    hash = "sha256-ZJ8y9DzngSkkGhD6JbCLDhaPTmVDxPwSTvUOl61I4xE=";
    stripRoot = false;
  };
  dlssSdkRoot = "${streamlineSdk}/external/ngx-sdk"; #needed libs for DLSS build

  blenderCUDA = pkgs.blender.override {
    cudaSupport = true;
  };
in
  blenderCUDA.overrideAttrs (finalAttrs: prevAttrs: {
    patches = []; #Patches break the build process
    src = pkgs.fetchgit {
      url = "https://projects.blender.org/pmoursnv/blender.git";
      rev = "7e9dab98484b8d9c87d95c18dde88967f33a530b";
      hash = "sha256-+tIdCPezx+SSXPbJt+tOnkyQxZOdfLQPaKlMbkpTtM4=";
      fetchSubmodules = true;
      fetchLFS = true;
    };

    nativeBuildInputs = prevAttrs.nativeBuildInputs ++ [pkgs.patchelf];

    cmakeFlags =
      prevAttrs.cmakeFlags
      ++ [
        "-DWITH_SYSTEM_GLOG=OFF" # Glog breaks the build
        "-DWITH_DLSS=ON"
        "-DDLSS_SDK_ROOT=${dlssSdkRoot}"
        "-DCYCLES_CUDA_BINARIES_ARCH=sm_89" # build for 4060 ti
      ];

    postInstall =
      (prevAttrs.postInstall or "")
      + ''
        echo "=== COPYING DLSS LIBRARIES ==="
        set -x
        cp --no-preserve=mode -v ${dlssLibs}/lib/Linux_x86_64/rel/libnvidia-ngx-dlss*.so* $out/bin/
        chmod u+w $out/bin/libnvidia-ngx-dlss*.so*
        chmod +x $out/bin/libnvidia-ngx-dlss*.so*

        # NGX looks for resource directory still, not sure it really needs it
        ln -s $out/share/blender/5.1 $out/bin/5.1
        set +x
      '';

    postFixup =
      (prevAttrs.postFixup or "")
      + ''
        echo "=== DLSS RPATH ==="
        set -x

        # I have no idea what dlss libraries need so I just copy RPATH of blender binary to them
        rpath=$(patchelf --print-rpath "$out/bin/.blender-wrapped")

        # Apply that RPATH (plus $out/bin) to every DLSS library
        for lib in $out/bin/libnvidia-ngx-dlss*.so*; do
          if [ -f "$lib" ]; then
            patchelf --set-rpath "$out/bin:$rpath" "$lib"
          fi
        done

        # Just in case blender binary can't see its own /bin directory
        patchelf --add-rpath "$out/bin" "$out/bin/.blender-wrapped"

        set +x
      '';
    # Please donw sue me
    meta =
      (prevAttrs.meta or {})
      // {
        license = (prevAttrs.meta.license or []) ++ [lib.licenses.unfree];
      };
  })
