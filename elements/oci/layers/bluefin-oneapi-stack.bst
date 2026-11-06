kind: stack

# Stack element for the Lunar Lake AI PC variant. Mirrors
# bluefin-nvidia-stack.bst in structure, but is simpler because OVMS is a
# containerized workload and ships no kernel modules — we don't need the
# post-compose depmod step the NVIDIA variant does.

depends:
  - oci/layers/bluefin-stack.bst
  - bluefin-oneapi/deps.bst
