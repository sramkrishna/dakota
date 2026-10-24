kind: manual

# GCC 14.2.0 — built as a side-by-side toolchain under /opt/gcc-14 so IGC
# (which doesn't compile with fdsdk's bleeding-edge GCC 16) can consume it
# via PATH override. mpc shipped in-tree (not in fdsdk); gmp/mpfr via fdsdk.

build-depends:
  # Host toolchain to compile GCC 14 with (fdsdk's GCC 16 is fine as host).
  - freedesktop-sdk.bst:components/gcc.bst
  - freedesktop-sdk.bst:components/binutils.bst

  # Build-system tools GCC's configure needs. fdsdk's minimal sandbox omits
  # most of these; GCC's autoconf-generated configure assumes a full POSIX
  # userland. Each one of these corresponds to a specific "command not found"
  # we have already hit or could predictably hit.
  - freedesktop-sdk.bst:components/make.bst
  - freedesktop-sdk.bst:components/sed.bst
  - freedesktop-sdk.bst:components/grep.bst
  - freedesktop-sdk.bst:components/gawk.bst
  - freedesktop-sdk.bst:components/m4.bst
  - freedesktop-sdk.bst:components/flex.bst
  - freedesktop-sdk.bst:components/bison.bst
  - freedesktop-sdk.bst:components/findutils.bst
  - freedesktop-sdk.bst:components/diffutils.bst
  - freedesktop-sdk.bst:components/perl.bst
  - freedesktop-sdk.bst:components/python3.bst
  - freedesktop-sdk.bst:components/patch.bst
  - freedesktop-sdk.bst:components/tar.bst
  - freedesktop-sdk.bst:components/gzip.bst
  - freedesktop-sdk.bst:components/xz.bst
  - freedesktop-sdk.bst:components/bzip2.bst
  - freedesktop-sdk.bst:components/zstd.bst
  - freedesktop-sdk.bst:components/zlib.bst
  - freedesktop-sdk.bst:components/pkg-config.bst
  - freedesktop-sdk.bst:components/which.bst

  # Math libraries GCC links against. mpc is NOT in fdsdk — shipped in-tree
  # via a second kind: tar source below.
  - freedesktop-sdk.bst:components/gmp.bst
  - freedesktop-sdk.bst:components/mpfr.bst

depends:
  - freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
  # GCC 14.2.0 release tarball. kind: tar auto-strips the top-level
  # gcc-14.2.0/ directory, so source lands directly at %{build-root}.
  - kind: tar
    url: ftp_gnu_org:gcc/gcc-14.2.0/gcc-14.2.0.tar.xz
    ref: a7b39bc69cbf9e25826c5a60ab26477001f7c08d85cec04bc0e29cabed6f3cc9

  # mpc 1.3.1 in-tree. GCC's configure finds this at ./mpc/ and builds it
  # as part of the gcc build. Avoids needing an mpc.bst since fdsdk has none.
  - kind: tar
    url: ftp_gnu_org:mpc/mpc-1.3.1.tar.gz
    base-dir: mpc-1.3.1
    directory: mpc
    ref: ab642492f5cf882b74aa0cb730cd410a81edcdbec895183ce930e706c1c759b8

variables:
  strip-binaries: ""

config:
  build-commands:
    - |
      mkdir build && cd build
      # libcody uses u8"..." literals which under C++20 (GCC 16 default)
      # return const char8_t[] instead of const char[]. -fno-char8_t restores
      # the C++17 behavior libcody expects. Baked into CXX itself so it
      # propagates even to GCC's internal makefiles that filter CXXFLAGS.
      export CXX="g++ -fno-char8_t"
      ../configure \
        --prefix=/opt/gcc-14 \
        --enable-languages=c,c++ \
        --disable-multilib \
        --disable-bootstrap \
        --disable-nls \
        --enable-shared \
        --enable-threads=posix \
        --with-system-zlib \
        --without-isl
      make -j$(nproc)

  install-commands:
    - |
      cd build
      DESTDIR=%{install-root} make install-strip
