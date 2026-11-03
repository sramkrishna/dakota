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

# nlohmann_json: openvino-genai's src/cpp/CMakeLists.txt:109 FetchContents
# v3.11.3. Hash matches what cmake declares.
- kind: tar
  url: github:nlohmann/json/archive/refs/tags/v3.11.3.tar.gz
  ref: 0d8ef5af7f9794e3263480193c491549b2ba6cc74bb018906202ada498a79406
  base-dir: json-3.11.3
  directory: thirdparty_prefetched/nlohmann_json

# minja: openvino-genai's src/cpp/CMakeLists.txt:117 FetchContents from a
# git repo at a specific commit. kind: git pinned to the same commit; cmake
# will use the staged tree instead of cloning when FETCHCONTENT_SOURCE_DIR_
# is set.
- kind: git
  url: github:google/minja.git
  track: main
  ref: 021c2293c187789ef13d56c6cfd89c9b134fd80f
  directory: thirdparty_prefetched/minja

# safetensors.h: openvino-genai's src/cpp/CMakeLists.txt:131 pins a specific
# commit. GitHub commit-archive URL serves tar.gz for any sha.
- kind: tar
  url: github:hsnyder/safetensors.h/archive/974a85d7dfd6e010558353226638bb26d6b9d756.tar.gz
  ref: 9aaf5961609601cf9aaa96582a207bce7c6e5fbf57ed2cc669bb7bde6a937d4b
  base-dir: safetensors.h-974a85d7dfd6e010558353226638bb26d6b9d756
  directory: thirdparty_prefetched/safetensors.h

# cxxopts: CLI parser used by cpp/text_generation samples. The other sample
# subdirs that would need cxxopts (image_generation) are patched out below.
- kind: tar
  url: github:jarro2783/cxxopts/archive/refs/tags/v3.3.1.tar.gz
  base-dir: cxxopts-3.3.1
  directory: thirdparty_prefetched/cxxopts
  ref: 3bfc70542c521d4b55a46429d808178916a579b28d048bd8c727ee76c39e2072

# Patch samples/CMakeLists.txt to only build text_generation samples. The
# image_generation / video_generation / visual_language_chat subdirs use
# file(DOWNLOAD ...) and ExternalProject_Add which bypass FetchContent and
# can't be redirected into hermetic bst — easier to drop them for the AI PC
# demo (we only need chat_sample + benchmark_genai).
- kind: patch
  path: elements/bluefin-oneapi/patches/openvino-genai-text-samples-only.patch
variables:
  strip-binaries: ""
  # ENABLE_PYTHON=OFF  — same reason as openvino (we don't ship pybindings)
  # ENABLE_SAMPLES=ON  — ship benchmark_genai + chat_sample for sanity checks
  # ENABLE_TESTS=OFF   — we don't run gtests
  # ENABLE_GGUF=OFF    — gguflib is for loading llama.cpp GGUF models; we're
  #                      using OpenVINO IR (via model-phi3-mini-int4.bst), so
  #                      disable to avoid prestaging another FetchContent.
  # ENABLE_XGRAMMAR=OFF — xgrammar provides constrained decoding (JSON mode,
  #                       grammar sampling). Not required for basic chat
  #                       completion; disable to avoid prestaging another dep.
  cmake-local: >-
    -DCMAKE_BUILD_TYPE=Release
    -DBUILD_SHARED_LIBS=ON
    -DENABLE_PYTHON=OFF
    -DENABLE_SAMPLES=ON
    -DENABLE_TESTS=OFF
    -DENABLE_GGUF=OFF
    -DENABLE_XGRAMMAR=OFF
    -DFETCHCONTENT_SOURCE_DIR_SENTENCEPIECE=%{build-root}/thirdparty_prefetched/sentencepiece
    -DFETCHCONTENT_SOURCE_DIR_PCRE2=%{build-root}/thirdparty_prefetched/pcre2
    -DFETCHCONTENT_SOURCE_DIR_NLOHMANN_JSON=%{build-root}/thirdparty_prefetched/nlohmann_json
    -DFETCHCONTENT_SOURCE_DIR_MINJA=%{build-root}/thirdparty_prefetched/minja
    "-DFETCHCONTENT_SOURCE_DIR_SAFETENSORS.H=%{build-root}/thirdparty_prefetched/safetensors.h"
    -DFETCHCONTENT_SOURCE_DIR_CXXOPTS=%{build-root}/thirdparty_prefetched/cxxopts
