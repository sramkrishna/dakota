# Intel graphics engine requires building in a directory with multiple clones in that directory as a single source tree.
kind: manual

build-depends:
- freedesktop-sdk.bst:components/cmake.bst
- freedesktop-sdk.bst:components/pkg-config.bst
- freedesktop-sdk.bst:components/bzip2.bst
- freedesktop-sdk.bst:components/ninja.bst
- freedesktop-sdk.bst:components/flex.bst
- freedesktop-sdk.bst:components/bison.bst
- freedesktop-sdk.bst:components/zlib.bst
- freedesktop-sdk.bst:components/zstd.bst
- freedesktop-sdk.bst:components/python3.bst
- freedesktop-sdk.bst:components/python3-mako.bst
- freedesktop-sdk.bst:components/gcc.bst
- freedesktop-sdk.bst:components/binutils.bst
- freedesktop-sdk.bst:components/patch.bst
- freedesktop-sdk.bst:components/git.bst
- freedesktop-sdk.bst:components/sed.bst   # also missing per the config.guess error
- freedesktop-sdk.bst:components/python3-pyyaml.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
- kind: git_repo
  url: github:intel/intel-graphics-compiler.git
  track: v2.40.13
  directory: igc-workspace/igc

  ref: v2.40.13-0-gcd6c33fbee6ccc897657c64b11eae6917cc8ff5e
- kind: git_repo
  url: github:KhronosGroup/SPIRV-LLVM-Translator.git
  track: llvm_release_170
  directory: igc-workspace/llvm-project/llvm/projects/llvm-spirv

  ref: v17.0.28-5-gda64845d0897f354e74231dd285d4098b022412a
- kind: git_repo
  url: github:llvm/llvm-project.git
  track: release/17.x
  directory: igc-workspace/llvm-project

  ref: llvmorg-17.0.6-0-g6009708b4367171ccdbf4b5905cb6a803753fe18
- kind: git_repo
  url: github:intel/opencl-clang.git
  track: ocl-open-170
  directory: igc-workspace/llvm-project/llvm/projects/opencl-clang

  ref: v17.0.10-0-g4ca4f1ac99f3a55cab60ca78696958be928b6c69

- kind: git_repo
  url: github:intel/vc-intrinsics.git
  track: v0.25.0
  directory: igc-workspace/vc-intrinsics

  # Two Khronos repos pinned to specific commits from IGC v2.40.13 release notes.
  # Using kind: tar + GitHub commit-archive URLs (immutable, SHA-indexed) because
  # git_repo wants to track a branch/tag, and main may have moved past these pins.
  ref: v0.25.0-0-g27f7c4f34738f5eaf7a045b77edf8d9e034443d8
- kind: tar
  url: github:KhronosGroup/SPIRV-Tools/archive/f80351511e9c4672e284842c7b124315c511078a.tar.gz
  ref: '08905bb11b2693d9f79f4842a53f20e48ab4282c2bf4fd6dd93ff0b9bebac41f' # to be filled: curl -sL <url> | sha256sum, or `bst source fetch`
  directory: igc-workspace/SPIRV-Tools

- kind: tar
  url: github:KhronosGroup/SPIRV-Headers/archive/575b6512579ebde466ed3dfc04e413439d14d95d.tar.gz
  ref: '775ee89eb77d067df3f5736e2b4bb2f5f3e39ead915f11f3d366139dcb42209d'
  directory: igc-workspace/SPIRV-Headers

variables:
  strip-binaries: ""

config:
  build-commands:
    - |
      git config --global user.email "builder@dakota.invalid"
      git config --global user.name "Dakota Builder"

      sed -i 's/set(CLANG_SUPPORTS_CL31 TRUE)/set(CLANG_SUPPORTS_CL31 FALSE)/' \
        igc-workspace/llvm-project/llvm/projects/opencl-clang/CMakeLists.txt

      cd igc-workspace
      mkdir build && cd build
      cmake ../igc \
        -G Ninja \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DCMAKE_INSTALL_LIBDIR=lib/x86_64-linux-gnu \
        -DCMAKE_BUILD_TYPE=Release \
        -DIGC_OPTION__ENABLE_LIT_TESTS=OFF \
        -DIGC_OPTION__ARCHITECTURE_TARGET=Linux64 \
        -DIGC_OPTION__LLVM_SOURCES_DIR=%{build-root}/igc-workspace/llvm-project \
        -DIGC_OPTION__LLVM_PREFERRED_VERSION=17.0.6 \
        -DLLVM_EXTERNAL_SPIRV_HEADERS_SOURCE_DIR=%{build-root}/igc-workspace/SPIRV-Headers \
        -DIGC_OPTION__LLVM_STOCK_SOURCES=ON \
        -DCCLANG_BUILD_INTREE_LLVM=TRUE \
	-Wno-error=cpp
        -DAPPLY_PATCHES=OFF \
        -DCMAKE_CXX_FLAGS="-include cstdint"
      cmake --build . --parallel $(nproc)

  install-commands:
  - |
    cd igc-workspace/build
    DESTDIR=%{install-root} cmake --install .
