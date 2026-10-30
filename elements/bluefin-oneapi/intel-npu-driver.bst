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
environment:
  # Avoid _FORTIFY_SOURCE redefinition (fdsdk sets =3, npu-driver sets =2).
  # Suppress missing-field-initializers-as-error: npu-driver v1.38.0
  # intentionally leaves newer L0 dditable extension slots as NULL
  # (ICD-style "not implemented" marker). The warning is correct, but
  # treating it as error prevents build on hardened toolchains.
  CFLAGS: '%{CFLAGS} -U_FORTIFY_SOURCE'
  CXXFLAGS: '%{CXXFLAGS} -U_FORTIFY_SOURCE -Wno-error=missing-field-initializers'

variables:
  strip-binaries: ""
  cmake-local: >-
    -DENABLE_NPU_COMPILER_BUILD=OFF
    -DENABLE_NPU_TESTS=OFF
    -DCMAKE_BUILD_TYPE=Release
    -DBUILD_SHARED_LIBS=ON
