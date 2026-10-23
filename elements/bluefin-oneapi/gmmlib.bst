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
    url: gmmlib:intel-gmmlib-22.10.2.tar.gz
    ref: 94d0038ef92bb65b86d08f004197c56f8d81f82f9ac7a25c202a88afd653a30b

variables:
  strip-binaries: ""
  cmake-local: >- 
    -DCMAKE_INSTALL_PREFIX=/usr
    -DCMAKE_BUILD_TYPE=Release

