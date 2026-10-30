kind: cmake

# OpenVINO inference runtime — the main AI PC component. Builds the
# runtime + CPU plugin + NPU plugin. GPU plugin skipped (requires IGC
# which is parked; GPU path is a step-2 ambition — see memory).
# Python bindings skipped (phi3-serve will consume via C++/libopenvino).
#
# Pinned to 2026.3.1 to match Intel's compat matrix with intel-npu-driver
# v1.38.0 (see release notes). 2026.4.x is available but introduces drift
# vs the npu-driver pin.
#
# Submodules fetched automatically via kind: git + checkout-submodules.
# OpenVINO vendors cnpy, pugixml, nlohmann_json, and nGraph as submodules.

build-depends:
- core/sandbox-tools.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst
- freedesktop-sdk-extra.bst:components/boost.bst
- bluefin-oneapi/onetbb.bst
- bluefin-oneapi/levelzero.bst
# intel-npu-driver provides the headers for the NPU plugin to link against.
- bluefin-oneapi/intel-npu-driver.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/libdrm.bst

sources:
- kind: git
  url: github:openvinotoolkit/openvino.git
  track: '2026.3.1'
  checkout-submodules: true

  ref: 759c5a6ab8c066af5f4bc5ebd04643706012a37d
variables:
  strip-binaries: ""
  # OpenVINO build toggles:
  #   ENABLE_INTEL_CPU=ON    — CPU plugin, needed as fallback
  #   ENABLE_INTEL_NPU=ON    — NPU plugin (the whole point)
  #   ENABLE_INTEL_GPU=OFF   — GPU plugin needs IGC (parked, see [[fdsdk-26]])
  #   ENABLE_PYTHON=OFF      — skip Python bindings tar-pit
  #   ENABLE_SAMPLES=OFF     — no sample apps
  #   ENABLE_TESTS=OFF       — no gtest-based tests
  #   ENABLE_WHEEL=OFF       — no Python wheel packaging
  #   THREADING=TBB          — use our onetbb.bst
  cmake-local: >-
    -DCMAKE_BUILD_TYPE=Release
    -DBUILD_SHARED_LIBS=ON
    -DENABLE_INTEL_CPU=ON
    -DENABLE_INTEL_NPU=ON
    -DENABLE_INTEL_GPU=OFF
    -DENABLE_PYTHON=OFF
    -DENABLE_SAMPLES=OFF
    -DENABLE_TESTS=OFF
    -DENABLE_WHEEL=OFF
    -DTHREADING=TBB
