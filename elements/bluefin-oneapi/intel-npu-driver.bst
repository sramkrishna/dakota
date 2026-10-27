kind: cmake

# intel/linux-npu-driver — userspace Level Zero driver for Intel NPU.
# Installs libze_intel_vpu.so + ICD manifest JSON. Pairs with:
#   - intel_vpu kernel module (in-tree since kernel 6.3)
#   - NPU firmware blobs (shipped by Dakota in /usr/lib/firmware/intel/vpu/)
#   - level-zero loader (our levelzero.bst — found at runtime via ICD scan)
#
# All sources use kind: tar for stability and consistency with the rest
# of our oneapi stack. Submodule commits pinned to what v1.38.0 expects
# per the upstream .gitmodules + resolved refs.

build-depends:
# Dakota's sandbox-tools provides sh, basic POSIX utils — without this
# the sandbox fails before cmake even starts.
- core/sandbox-tools.bst
- freedesktop-sdk.bst:components/cmake.bst
- freedesktop-sdk.bst:components/pkg-config.bst
- freedesktop-sdk.bst:components/ninja.bst
- freedesktop-sdk.bst:components/bzip2.bst
- freedesktop-sdk.bst:components/openssl.bst
- freedesktop-sdk.bst:components/libdrm.bst
- freedesktop-sdk.bst:components/lz4.bst
# systemd.bst dropped — transitively pulls gnome-build-meta's systemd-base
# which doesn't build under fdsdk 26.08rc.2's GCC 16. If intel-npu-driver
# actually needs libudev, add it back and figure out a lighter path.
# Need L0 headers to build the ICD driver interface.
- bluefin-oneapi/levelzero.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
  # Main project — v1.38.0 release source.
- kind: tar
  url: github:intel/linux-npu-driver/archive/refs/tags/v1.38.0.tar.gz

  # Submodules, pinned to commits per upstream v1.38.0's .gitmodules.
  # Each extracts under third_party/ using kind: tar's default
  # auto-strip-top-dir behavior; base-dir not needed.
  ref: 5584d03dcd37893b49cdb5f327578ab9afbc4a055d0fb66714e17c98c2821fd4
- kind: tar
  url: github:intel/level-zero-vpu-extensions/archive/ddbf8d65e2e22150e23efd383839aa80f84d4dac.tar.gz
  directory: third_party/level-zero-npu-extensions

  ref: 0c8e27a3da0ed0b6947cfa8e6019dfd3d104226f6217a557de723ad288db79a4
- kind: tar
  url: github:openvinotoolkit/npu_compiler_elf/archive/edbd3b0dbb6f51f4f6c18aba3b26d4c20b1a5964.tar.gz
  directory: third_party/npu_compiler_elf

  ref: dff7c3e5c430b5d3ba24d77b4723fbcf5deea968701ce9f3f9c8ad18903665a8
- kind: tar
  url: github:google/googletest/archive/cd8e73f067129f8489e35c7b51c7a68552b289d2.tar.gz
  directory: third_party/googletest

  ref: 925c0f000318521aadc1ea9b6b28bcbce2500a9ed405918a8e87e1b54aec5070
- kind: tar
  url: github:jbeder/yaml-cpp/archive/c5e65360373d1d99d6b6848c991cd4fcee435009.tar.gz
  directory: third_party/yaml-cpp

  ref: aa33e48f7ea186fa8ccbc3eb9c5a85b831f3f56cf0920764ba390eb090ae7160
variables:
  strip-binaries: ""
  # Point cmake at the staged L0 headers from levelzero.bst (lands under
  # /usr via fdsdk's cmake plugin defaults).
  cmake-local: >-
    -DCMAKE_BUILD_TYPE=Release
    -DENABLE_NPU_COMPILER_BUILD=OFF
    -DENABLE_NPU_TESTS=OFF
    -DBUILD_SHARED_LIBS=ON
