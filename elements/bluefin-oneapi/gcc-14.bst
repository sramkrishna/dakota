kind: manual

build-depends:
  # Minimal toolchain to compile gcc (we use fdsdk's gcc 16 to compile gcc 14)
- freedesktop-sdk.bst:components/gcc.bst
- freedesktop-sdk.bst:components/binutils.bst
- freedesktop-sdk.bst:components/make.bst
- freedesktop-sdk.bst:components/flex.bst
- freedesktop-sdk.bst:components/bison.bst
- freedesktop-sdk.bst:components/m4.bst
- freedesktop-sdk.bst:components/gmp.bst
- freedesktop-sdk.bst:components/mpfr.bst         # verify fdsdk has this
- freedesktop-sdk.bst:components/zlib.bst
- freedesktop-sdk.bst:components/zstd.bst
- freedesktop-sdk.bst:components/bzip2.bst
- freedesktop-sdk.bst:components/xz.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
- kind: tar
  url: ftp_gnu_org:gcc/gcc-14.2.0/gcc-14.2.0.tar.xz

  ref: a7b39bc69cbf9e25826c5a60ab26477001f7c08d85cec04bc0e29cabed6f3cc9
- kind: tar
  url: ftp_gnu_org:mpc/mpc-1.3.1.tar.gz
  base-dir: mpc-1.3.1
  directory: gcc-14.2.0/mpc

  ref: ab642492f5cf882b74aa0cb730cd410a81edcdbec895183ce930e706c1c759b8
variables:
  strip-binaries: ""

config:
  build-commands:
  - |
    mkdir build && cd build
    ../gcc-14.2.0/configure \
      --prefix=/opt/gcc-14 \
      --enable-languages=c,c++ \
      --disable-multilib \
      --disable-bootstrap \
      --disable-nls \
      --enable-shared \
      --enable-threads=posix \
      --with-system-zlib
    make -j$(nproc)

  install-commands:
  - |
    cd build
    DESTDIR=%{install-root} make install-strip
    # Create a convenience symlink layout under /
    # so IGC can find gcc-14 as a drop-in `gcc` via PATH prefix.

