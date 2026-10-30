kind: junction

# fdsdk-extra — companion project to fdsdk providing additional components
# (boost, qt, etc.) not in base fdsdk. Lets us depend on boost.bst and other
# components not shipped in Dakota's main freedesktop-sdk.bst junction.
#
# Tracks the same 26.08 release line as Dakota's fdsdk junction for ABI
# consistency (same GCC 16 / libstdc++16 era).

sources:
- kind: git_repo
  url: gitlab:freedesktop-sdk/freedesktop-sdk-extra.git
  track: freedesktop-sdk-extra-26.08*
  ref: freedesktop-sdk-extra-26.08.4-0-g1c3778a286f87e2202d9af7b92542e5d49d50929

config:
  # freedesktop-sdk-extra internally references its own freedesktop-sdk
  # junction. Redirect that to Dakota's existing freedesktop-sdk.bst so
  # we don't end up with two instances of the fdsdk project loaded in
  # parallel. Same pattern Dakota uses for gnome-build-meta.bst.
  overrides:
    freedesktop-sdk.bst: freedesktop-sdk.bst
    plugins/buildstream-plugins-community.bst: plugins/buildstream-plugins-community.bst
