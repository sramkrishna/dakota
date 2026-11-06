kind: import

# OVMS — OpenVINO Model Server deployed as a podman quadlet container.
#
# This element only stages the systemd quadlet unit + its config file onto the
# image. The container image itself is pulled from docker.io on first start
# (keeps the bootc image small; see
# [[feedback-from-source-vs-container]] in auto-memory for why we chose the
# container route over building OVMS from bazel).
#
# Runtime prerequisites (host must provide):
#   - podman (default in bluefin)
#   - systemd quadlet generator (default on systemd 252+; bluefin is well past)
#   - intel-npu-driver.bst — creates /dev/accel/accel0 + udev rules + firmware
#   - level-zero.bst       — transitive dep of the NPU driver's user-space
#   - model-phi3-mini-int4.bst — model .xml/.bin at /usr/share/models/phi3-mini-int4/
#
# To iterate on the quadlet without a rebuild, edit the file in-place on the
# target: /etc/containers/systemd/ovms.container  → systemctl daemon-reload
# → systemctl restart ovms

depends:
- bluefin-oneapi/intel-npu-driver.bst
- bluefin-oneapi/level-zero.bst
- bluefin-oneapi/model-phi3-mini-int4.bst

sources:
- kind: local
  path: elements/bluefin-oneapi/ovms

variables:
  # Where systemd looks for quadlet unit definitions. /etc/ beats /usr/ here
  # because bootc images are read-only at /usr but /etc is writable, so an
  # operator can `systemctl edit` or override the unit without a new deploy.
  quadlet-dir: /etc/containers/systemd

config:
  install-commands:
  - mkdir -p %{install-root}%{quadlet-dir}
  - install -m 0644 ovms.container      %{install-root}%{quadlet-dir}/ovms.container
  # Stage the pre-generated mediapipe graph alongside the model files. OVMS
  # reads this at serve-time; models_path: "./" inside it resolves to this
  # same directory, where model-phi3-mini-int4.bst has placed openvino_model.{xml,bin}.
  - mkdir -p %{install-root}/usr/share/models/phi3-mini-int4
  - install -m 0644 phi3-mini-int4-graph.pbtxt %{install-root}/usr/share/models/phi3-mini-int4/graph.pbtxt
