kind: import

# Phi-3-mini-4k-instruct INT4 OpenVINO IR, pulled from HuggingFace one file
# at a time via HTTPS `resolve/main/<file>` endpoints (HF transparently
# handles the LFS redirect server-side; we just see bytes).
#
# `kind: remote` + sha256 per file gives us:
#   - no git-lfs plumbing in bst (kind: git + LFS fundamentally doesn't work
#     with bst's --shared bare mirror model)
#   - no model mirror we have to host or license
#   - per-file content pinning
#
# Each file's ref is populated by:
#     just bst source track bluefin-oneapi/model-phi3-mini-int4.bst
# (run on brigid so the edits land where git lives).

sources:
- kind: remote
  url: huggingface:OpenVINO/Phi-3-mini-4k-instruct-int4-ov/resolve/main/openvino_model.xml
  filename: openvino_model.xml

  ref: 10fa11086e64b5d0a86125eac358730f397c9978bf69e5ad01c3ed3442e34fa5
- kind: remote
  url: huggingface:OpenVINO/Phi-3-mini-4k-instruct-int4-ov/resolve/main/openvino_model.bin
  filename: openvino_model.bin

  ref: 4966cb2c4f416cb20b934a7130d4aa5aefa5007b56c817b55dcfe53b1506c415
- kind: remote
  url: huggingface:OpenVINO/Phi-3-mini-4k-instruct-int4-ov/resolve/main/openvino_tokenizer.xml
  filename: openvino_tokenizer.xml

  ref: b80890839c5f58a8d0aa096f83f8e5afa678f6dc94ff8f0ed5191eb251922936
- kind: remote
  url: huggingface:OpenVINO/Phi-3-mini-4k-instruct-int4-ov/resolve/main/openvino_tokenizer.bin
  filename: openvino_tokenizer.bin

  ref: 012a18fef2df281b8293a03448630081625d563d29d199b482a64751609a5698
- kind: remote
  url: huggingface:OpenVINO/Phi-3-mini-4k-instruct-int4-ov/resolve/main/openvino_detokenizer.xml
  filename: openvino_detokenizer.xml

  ref: 99fea2a8f2196611d6117354968edcd5a3ae2cb20a65458e73a21c4ffa9a33ef
- kind: remote
  url: huggingface:OpenVINO/Phi-3-mini-4k-instruct-int4-ov/resolve/main/openvino_detokenizer.bin
  filename: openvino_detokenizer.bin

  ref: abf0a5ac7698c27f1f3a8573b76a628e4a6a2c7eaddc7dd549ee3607a34d4061
- kind: remote
  url: huggingface:OpenVINO/Phi-3-mini-4k-instruct-int4-ov/resolve/main/config.json
  filename: config.json

  ref: 02924e26a524aaaedd1fac09f7e28f845cef4fd9d7413c64104fadebd336ad07
- kind: remote
  url: huggingface:OpenVINO/Phi-3-mini-4k-instruct-int4-ov/resolve/main/generation_config.json
  filename: generation_config.json

  ref: 57525c015bbf567bd8f398a22a23fbf297a2e0f7e33342701bd11db09fbc8518
- kind: remote
  url: huggingface:OpenVINO/Phi-3-mini-4k-instruct-int4-ov/resolve/main/tokenizer.json
  filename: tokenizer.json

  ref: 3cb815b904d82b82b25dcd90edd00e71a5ee5443472ad611bcb84f1339300647
- kind: remote
  url: huggingface:OpenVINO/Phi-3-mini-4k-instruct-int4-ov/resolve/main/tokenizer_config.json
  filename: tokenizer_config.json

  ref: 83cc1cd0a237101b3bd508a40e53a066548493525a2a49572e12fe467fd119c0
- kind: remote
  url: huggingface:OpenVINO/Phi-3-mini-4k-instruct-int4-ov/resolve/main/special_tokens_map.json
  filename: special_tokens_map.json

  ref: 474d699677e264edd3851559548cbbb61801ad8da6b249c81455007602313c34
config:
  source: /
  target: /usr/share/models/phi3-mini-int4
