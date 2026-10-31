kind: import

# Phi-3-mini-4k-instruct INT4, pre-converted to OpenVINO IR by Intel.
# Staged into /usr/share/models/phi3-mini-int4/.
#
# The HuggingFace repo stores model weights (openvino_model.bin, tokenizer
# .bin files) via git-lfs. Build THIS element without the GIT_LFS_SKIP_SMUDGE
# workaround (that's only needed for openvino's orphaned-doc-blob case):
#
#     just bst build bluefin-oneapi/model-phi3-mini-int4.bst
#
# bst's `kind: git` runs `git checkout` which triggers lfs smudge — HF's lfs
# is well-maintained so smudging actually downloads the real ~2.2 GB of
# weights (vs the openvino case where one orphan broke the whole checkout).

sources:
- kind: git
  url: huggingface:OpenVINO/Phi-3-mini-4k-instruct-int4-ov.git
  track: main
  checkout-submodules: false

config:
  source: /
  target: /usr/share/models/phi3-mini-int4
