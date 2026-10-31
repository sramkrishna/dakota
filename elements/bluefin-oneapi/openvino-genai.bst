kind: cmake

# OpenVINO GenAI — Intel's higher-level API over libopenvino for LLM/VLM/
# diffuser inference. Provides ov::genai::LLMPipeline (tokenize + generate +
# detokenize + streaming + chat template application) and sampling/beam-search
# helpers. phi3-serve.bst will link against this.
#
# Pinned 2026.3.0.0 to pair with openvino.bst's 2026.3.1 (same release line;
# Intel keeps GenAI and the runtime in lockstep by major.minor).
#
# openvino-genai bundles openvino_tokenizers as a submodule — we pull the
# whole tree with checkout-submodules: true.

build-depends:
- core/sandbox-tools.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst
- freedesktop-sdk.bst:components/grep.bst
- freedesktop-sdk.bst:components/sed.bst
- bluefin-oneapi/onetbb.bst
- bluefin-oneapi/openvino.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- bluefin-oneapi/onetbb.bst
- bluefin-oneapi/openvino.bst

sources:
- kind: git
  url: github:openvinotoolkit/openvino.genai.git
  track: 2026.3.0.0
  checkout-submodules: true

  ref: bd8d6542e3ca1ac30042d5d8d4202ce00b5f4af0
variables:
  strip-binaries: ""
  # ENABLE_PYTHON=OFF — same reason as openvino (we don't ship pybindings)
  # ENABLE_SAMPLES=ON — ship benchmark_genai + chat_sample for sanity checks
  # ENABLE_TESTS=OFF — we don't run gtests
  cmake-local: >-
    -DCMAKE_BUILD_TYPE=Release
    -DBUILD_SHARED_LIBS=ON
    -DENABLE_PYTHON=OFF
    -DENABLE_SAMPLES=ON
    -DENABLE_TESTS=OFF
