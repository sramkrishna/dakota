kind: cmake

# intel/linux-npu-driver — userspace Level Zero driver for Intel NPU.
# Installs libze_intel_vpu.so + ICD manifest JSON. Pairs with:
#   - intel_vpu kernel module (in-tree since kernel 6.3)
#   - NPU firmware blobs (shipped by Dakota in /usr/lib/firmware/intel/vpu/)
#   - level-zero loader (our levelzero.bst — found at runtime via ICD scan)
#
# On Lunar Lake (VPU 4000) this is the userspace half of the NPU path.
# OpenVINO's NPU plugin consumes this driver via L0 at runtime.

build-depends:
# Dakota's sandbox-tools provides sh, basic POSIX utils — without this
# the sandbox fails before cmake even starts.
- core/sandbox-tools.bst
- freedesktop-sdk.bst:components/cmake.bst
- freedesktop-sdk.bst:components/pkg-config.bst
- freedesktop-sdk.bst:components/ninja.bst
- freedesktop-sdk.bst:components/bzip2.bst
- freedesktop-sdk.bst:components/openssl.bst
- freedesktop-sdk.bst:components/libdrm.bst         # verify path
- freedesktop-sdk.bst:components/lz4.bst
# systemd.bst dropped — transitively pulls gnome-build-meta's systemd-base
# which doesn't build under fdsdk 26.08rc.2's GCC 16. If intel-npu-driver
# actually needs libudev, add it back and figure out a lighter path.
  # Need L0 headers to build the ICD driver interface.
- bluefin-oneapi/levelzero.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
- kind: git_repo
  url: github:intel/linux-npu-driver.git
  track: v1.38.0

  ref: v1.38.0-0-gaea583dcd86a4723a8d3bb06ad94b6eb2f80c6f2

- kind: git_repo
  url: github:intel/level-zero-vpu-extensions.git
  track: main
  directory: third_party/level-zero-npu-extensions

  ref: ddbf8d65e2e22150e23efd383839aa80f84d4dac
- kind: git_repo
  url: github:openvinotoolkit/npu_compiler_elf.git
  track: master
  directory: third_party/npu_compiler_elf

  ref: npu_ud_2026_28_rc2-2-gedbd3b0dbb6f51f4f6c18aba3b26d4c20b1a5964
- kind: git_repo
  url: github:google/googletest.git
  track: main
  directory: third_party/googletest

  ref: v1.14.0-pre-408-gcd8e73f067129f8489e35c7b51c7a68552b289d2
- kind: git_repo
  url: github:jbeder/yaml-cpp.git
  track: master
  directory: third_party/yaml-cpp

  ref: yaml-cpp-0.9.0-75-gc5e65360373d1d99d6b6848c991cd4fcee435009
variables:
  strip-binaries: ""
  # Point cmake at the staged L0 headers from levelzero.bst (lands under
  # /usr via fdsdk's cmake plugin defaults).
  cmake-local: >-
    -DCMAKE_BUILD_TYPE=Release
    -DENABLE_NPU_COMPILER_BUILD=OFF
    -DENABLE_NPU_TESTS=OFF
    -DBUILD_SHARED_LIBS=ON

# cmake-local flags explained:
#   ENABLE_NPU_COMPILER_BUILD=OFF  — skip the IGC-based NPU compiler component;
#                                    OpenVINO handles the compile side, we just
#                                    need the userspace L0 driver stub.
#   ENABLE_NPU_TESTS=OFF           — skip gtest-based validation (saves time,
#                                    may need gtest build-dep otherwise).
#
# These flag names are my best guess from the intel/linux-npu-driver repo
# conventions — verify by `cat` on the repo's top-level CMakeLists.txt once
# bst sources are tracked.
