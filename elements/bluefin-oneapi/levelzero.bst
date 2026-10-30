kind: cmake

build-depends:
  - freedesktop-sdk.bst:components/cmake.bst
  - freedesktop-sdk.bst:components/pkg-config.bst
  - core/sandbox-tools.bst

depends:
  - freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
  - freedesktop-sdk.bst:components/bzip2.bst
  - freedesktop-sdk.bst:components/ninja.bst
  - freedesktop-sdk.bst:components/gcc.bst
  - freedesktop-sdk.bst:components/binutils.bst


sources:
  # level-zero releases — pinned to v1.32.0 to match intel-npu-driver v1.38.0's
  # compat matrix. Newer L0 (1.34) added dditable fields npu-driver v1.38.0
  # doesn't populate; using the matching version keeps the function pointer
  # tables consistent at runtime.
  - kind: tar
    url: levelzero:v1.32.0.tar.gz
    ref: b658d3be89b2ea3c5e6b3214592acb58a4875e738184b1a4cc7e9cf878b5f7b9

variables:
  strip-binaries: ""
  cmake-local: >- 
    -DCMAKE_INSTALL_PREFIX=/usr
    -DCMAKE_BUILD_TYPE=Release

