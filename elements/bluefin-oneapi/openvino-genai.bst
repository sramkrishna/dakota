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

# openvino_tokenizers (a submodule of openvino-genai) uses FetchContent to
# pull sentencepiece from GitHub at configure time. bst sandbox is hermetic,
# so we pre-stage the exact tarball it wants (URL+sha256 copied from
# thirdparty/openvino_tokenizers/src/CMakeLists.txt) at a known relative
# path, then point FetchContent at it via FETCHCONTENT_SOURCE_DIR_SENTENCEPIECE
# in cmake-local below.
- kind: tar
  url: github:google/sentencepiece/releases/download/v0.2.1/sentencepiece-0.2.1.tar.gz
  ref: 8138cec27c2f2282f4a34d9a016e3374cd40e5c6e9cb335063db66a0a3b71fad
  base-dir: sentencepiece-0.2.1
  directory: thirdparty_prefetched/sentencepiece

# pcre2: openvino_tokenizers also FetchContents this at configure time
# (see thirdparty/openvino_tokenizers/src/CMakeLists.txt:190). The upstream
# FetchContent references the .zip; we use the equivalent .tar.gz from the
# same release so core kind: tar works without registering community-plugins'
# kind: zip. Content is identical; FETCHCONTENT_SOURCE_DIR_PCRE2 bypasses
# cmake's URL_HASH check so the archive format doesn't matter.
- kind: tar
  url: github:PCRE2Project/pcre2/releases/download/pcre2-10.46/pcre2-10.46.tar.gz
  base-dir: pcre2-10.46
  directory: thirdparty_prefetched/pcre2
  ref: 8d28d7f2c3b970c3a4bf3776bcbb5adfc923183ce74bc8df1ebaad8c1985bd07
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
    -DFETCHCONTENT_SOURCE_DIR_SENTENCEPIECE=%{build-root}/thirdparty_prefetched/sentencepiece
    -DFETCHCONTENT_SOURCE_DIR_PCRE2=%{build-root}/thirdparty_prefetched/pcre2
