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
  # level-zero releases
  - kind: tar
    url: levelzero:v1.34.0.tar.gz
    ref: 5856f6ff3ad465f8ea5dc7b7dc4f8b3d436d826f2751f91896d204b638fdc0d9

variables:
  strip-binaries: ""
  cmake-local: >- 
    -DCMAKE_INSTALL_PREFIX=/usr
    -DCMAKE_BUILD_TYPE=Release

