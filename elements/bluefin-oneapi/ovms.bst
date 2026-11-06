kind: import

# OVMS — OpenVINO Model Server deployed as a podman quadlet container.
#
# This element only stages the systemd quadlet unit + the mediapipe graph.pbtxt
# onto the image. The container image itself is pulled from docker.io on first
# start (keeps the bootc image small; see
# [[feedback-from-source-vs-container]] in auto-memory for why we chose the
# container route over building OVMS from bazel).
#
# Runtime prerequisites (host must provide):
#   - podman (default in bluefin)
#   - systemd quadlet generator (default on systemd 252+; bluefin is well past)
#   - intel-npu-driver.bst — creates /dev/accel/accel0 + udev rules + firmware
#   - levelzero.bst        — transitive dep of the NPU driver's user-space
#   - model-phi3-mini-int4.bst — model .xml/.bin at /usr/share/models/phi3-mini-int4/
#
# To iterate on the quadlet without a rebuild, edit the file in-place on the
# target: /etc/containers/systemd/ovms.container  → systemctl daemon-reload
# → systemctl restart ovms

depends:
- bluefin-oneapi/intel-npu-driver.bst
- bluefin-oneapi/levelzero.bst
- bluefin-oneapi/model-phi3-mini-int4.bst

sources:
- kind: local
  path: elements/bluefin-oneapi/ovms

# The source tree mirrors final install paths:
#   ovms/etc/containers/systemd/ovms.container
#   ovms/usr/share/models/phi3-mini-int4/graph.pbtxt
# so we just drop them into / verbatim.
config:
  source: /
  target: /
