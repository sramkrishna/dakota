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
# OpenVINO's developer_package/target_flags.cmake uses external `grep` (and
# `sed` elsewhere) inside execute_process pipelines for feature detection.
# fdsdk's build sandbox is minimal and doesn't ship these by default — add
# them explicitly so configure can run.
- freedesktop-sdk.bst:components/grep.bst
- freedesktop-sdk.bst:components/sed.bst
# Python3 is needed by the vendored ONNX submodule's CMakeLists to generate
# protobuf bindings at configure time (thirdparty/onnx/onnx/CMakeLists.txt
# calls find_package(Python3 REQUIRED COMPONENTS Interpreter)). Also the
# knob that gates ENABLE_OV_ONNX_FRONTEND ON/OFF in openvino itself
# (features.cmake:148) is a find_host_package(Python3) check.
- freedesktop-sdk.bst:components/python3.bst

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
  #   ENABLE_SAMPLES=ON      — brings in benchmark_app for sanity-checking the
  #     runtime + plugins (even if it's a CV-oriented benchmark). Costs ~15
  #     extra sample binaries but we need SOMETHING that exercises libopenvino.so.
  #   ENABLE_OV_ONNX_FRONTEND=ON / ENABLE_OV_TF_FRONTEND=ON — both default ON
  #     but are auto-disabled by openvino's cmake if `find_host_package(Python3)`
  #     fails at configure time (see cmake/features.cmake:148). The sandbox
  #     doesn't always expose python3 on PATH, so we force-enable. Both are
  #     required by openvino-genai's openvino_tokenizers submodule.
  #   ENABLE_TESTS=OFF       — no gtest-based tests
  #   ENABLE_WHEEL=OFF       — no Python wheel packaging
  #   THREADING=TBB          — use our onetbb.bst
  #   ENABLE_SYSTEM_TBB=ON   — bst sandbox is hermetic (no network); use
  #     onetbb.bst via find_package(TBB) rather than letting openvino
  #     download its own prebuilt tarball from storage.openvinotoolkit.org.
  cmake-local: >-
    -DCMAKE_BUILD_TYPE=Release
    -DBUILD_SHARED_LIBS=ON
    -DENABLE_INTEL_CPU=ON
    -DENABLE_INTEL_NPU=ON
    -DENABLE_INTEL_GPU=OFF
    -DENABLE_PYTHON=OFF
    -DENABLE_SAMPLES=ON
    -DENABLE_TESTS=OFF
    -DENABLE_WHEEL=OFF
    -DTHREADING=TBB
    -DENABLE_SYSTEM_TBB=ON
    -DENABLE_TBBBIND_2_5=OFF
    -DENABLE_JS=OFF
    -DCPACK_GENERATOR=DEB
    -DENABLE_OV_ONNX_FRONTEND=ON
    -DENABLE_OV_TF_FRONTEND=ON
