# Chunkah ownership for the bluefin-oneapi compose artifact, mirroring
# oci/chunkah/bluefin-nvidia.bst in structure.

kind: chunkah-ownership

build-depends:
  - oci/layers/bluefin-oneapi.bst
  - oci/layers/bluefin-oneapi-stack.bst
  - oci/layers/brew-toolchain.bst
  - oci/chunkah/brew-toolchain.bst

config:
  layer-dependency: oci/layers/bluefin-oneapi.bst
  provenance-dependencies:
    - oci/layers/bluefin-oneapi-stack.bst
    - oci/layers/brew-toolchain.bst
  metadata-dependencies:
    - oci/chunkah/brew-toolchain.bst
  inherit-from-components:
    - oci/layers/brew-toolchain.bst
