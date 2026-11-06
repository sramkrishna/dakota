kind: stack

# Aggregator for the Lunar Lake AI PC variant's runtime elements. Mirrors the
# bluefin-nvidia/deps.bst pattern. Contains only what must ship in the final
# image — openvino.bst / openvino-genai.bst / onetbb.bst / phi3-serve.bst are
# intentionally NOT included here: OVMS as a container carries its own
# openvino stack, so there's nothing on the serving path that embeds libopenvino
# in the host image. Those elements remain buildable for local dev and the
# future oneAPI integration step; they just don't bloat the bootc image.

depends:
  # NPU userspace driver + firmware. Creates /dev/accel/accel0 via udev rules
  # and ships level-zero's libze_loader.so transitively (its own build-dep).
  - bluefin-oneapi/intel-npu-driver.bst

  # Level Zero runtime, needed at serve time by the NPU driver's userspace
  # path. Explicit here for provenance even though intel-npu-driver.bst
  # already depends on it.
  - bluefin-oneapi/levelzero.bst

  # Phi-3-mini-4k-instruct-int4-ov model files staged at
  # /usr/share/models/phi3-mini-int4/ — bind-mounted RO into the OVMS container.
  - bluefin-oneapi/model-phi3-mini-int4.bst

  # OVMS quadlet + mediapipe graph.pbtxt. On boot systemd generates
  # ovms.service from the quadlet, which pulls openvino/model_server:2026.3
  # and serves the OpenAI-compatible API on 127.0.0.1:8080.
  - bluefin-oneapi/ovms.bst
