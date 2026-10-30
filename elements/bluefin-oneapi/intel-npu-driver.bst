kind: cmake

# intel/linux-npu-driver — userspace Level Zero driver for Intel NPU.
# From-source build. Submodules fetched automatically via kind: git +
# submodules: true, matching upstream's recommended workflow
# (git clone --recurse-submodules).

build-depends:
- core/sandbox-tools.bst
# Buildsystem-cmake pulls cmake + ninja + the whole toolchain.
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst
- freedesktop-sdk-extra.bst:components/boost.bst
# Need L0 headers to build the ICD driver interface.
- bluefin-oneapi/levelzero.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/libdrm.bst

sources:
- kind: git
  url: github:intel/linux-npu-driver.git
  track: v1.38.0
  checkout-submodules: true

  ref: aea583dcd86a4723a8d3bb06ad94b6eb2f80c6f2
variables:
  strip-binaries: ""
  # -U_FORTIFY_SOURCE: fdsdk sets =3 globally, npu-driver sets =2 → "redefined"
  #   warning that -Werror promotes to failure. -U undefines so npu-driver's
  #   =2 is the sole definition.
  # -Wno-error=missing-field-initializers: npu-driver v1.38.0 intentionally
  #   leaves newer L0 dditable extension slots NULL (ICD "not implemented"
  #   marker). Warning stays visible but doesn't fail the build.
  # Quotes keep each -D...= value as one shell arg despite the embedded space.
  cmake-local: >-
    -DENABLE_NPU_COMPILER_BUILD=OFF
    -DENABLE_NPU_TESTS=OFF
    -DCMAKE_BUILD_TYPE=Release
    -DBUILD_SHARED_LIBS=ON
    "-DCMAKE_C_FLAGS=-U_FORTIFY_SOURCE"
    "-DCMAKE_CXX_FLAGS=-U_FORTIFY_SOURCE -Wno-error=missing-field-initializers"
