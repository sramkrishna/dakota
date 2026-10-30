kind: cmake

# oneAPI Threading Building Blocks — threading backend used by OpenVINO's
# runtime (and most Intel compute libraries). Apache 2.0, pure cmake.
# v2023.2.0 is the current latest; OpenVINO 2026.3.1 is compatible with
# this line.

build-depends:
- core/sandbox-tools.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
- kind: tar
  url: github:oneapi-src/oneTBB/archive/refs/tags/v2023.2.0.tar.gz
  # ref: '' — run `just bst source track bluefin-oneapi/onetbb.bst` to fill

  ref: 80cb62e62defeee67ea1885a6f72d97ac81404f8fde9cded62fb51524808a30c
variables:
  strip-binaries: ""
  # TBB_TEST=OFF: skip the gtest-based test suite (saves build time + a dep)
  # TBB_EXAMPLES=OFF: skip the examples
  # TBB_STRICT=OFF: oneTBB has a flag that promotes warnings to errors
  #   when ON. We've been bitten by that pattern across every other element
  #   in this stack (-Werror combined with fdsdk's hardened CFLAGS), so
  #   defensively keep it off.
  cmake-local: >-
    -DCMAKE_BUILD_TYPE=Release
    -DBUILD_SHARED_LIBS=ON
    -DTBB_TEST=OFF
    -DTBB_EXAMPLES=OFF
    -DTBB_STRICT=OFF
