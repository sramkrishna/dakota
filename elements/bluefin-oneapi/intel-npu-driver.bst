kind: cmake

# intel/linux-npu-driver — userspace Level Zero driver for Intel NPU.
# From-source build. Submodules fetched automatically via kind: git +
# submodules: true, matching upstream's recommended workflow
# (git clone --recurse-submodules).

build-depends:
- core/sandbox-tools.bst
# Buildsystem-cmake pulls cmake + ninja + the whole toolchain.
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst
- freedesktop-sdk.bst:components/boost.bst
# Need L0 headers to build the ICD driver interface.
- bluefin-oneapi/levelzero.bst

depends:
- freedesktop-sdk.bst:bootstrap-import.bst
- freedesktop-sdk.bst:components/libdrm.bst

sources:
- kind: git
  url: github:intel/linux-npu-driver.git
  track: v1.38.0
  checkout-submodules: true

variables:
  strip-binaries: ""
  cmake-local: >-
    -DENABLE_NPU_COMPILER_BUILD=ON
    -DENABLE_NPU_TESTS=OFF
    -DCMAKE_BUILD_TYPE=Release
    -DBUILD_SHARED_LIBS=ON
    -DCMAKE_C_FLAGS=-U_FORTIFY_SOURCE
    -DCMAKE_CXX_FLAGS=-U_FORTIFY_SOURCE
    -DCMAKE_C_FLAGS_INIT=-fcf-protection=none
    -DCMAKE_CXX_FLAGS_INIT=-fcf-protection=none
