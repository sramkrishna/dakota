# System info tool; common's ublue-fastfetch wrapper expects it on the image.
kind: cmake

sources:
- kind: git_repo
  url: github:fastfetch-cli/fastfetch.git
  track: "[0-9]*.[0-9]*.[0-9]*"
  ref: 2.70.0-0-g17bb3fd2384bd814b421d73b8c8b8d08e06cfa26

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-cmake.bst
# Headers enable wayland/drm/dbus features; the libs are dlopen'd at runtime.
- freedesktop-sdk.bst:components/wayland.bst
- freedesktop-sdk.bst:components/libdrm.bst
- freedesktop-sdk.bst:components/dbus.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
