#!/bin/bash
# SPDX-License-Identifier: GPL-2.0

tools/bazel run \
    --config=stamp \
    --config=bluejay \
    //private/devices/google/bluejay:gs101_bluejay_dist "$@" || exit 1

sign_file=$(mktemp)
trap '{ rm -f -- "$sign_file"; }' EXIT
prebuilts/clang/host/linux-x86/clang-r487747c/bin/clang aosp/scripts/sign-file.c -lssl -lcrypto -o ${sign_file}
find out/comet/dist -type f -name "*.ko" \
  -exec ${sign_file} sha256 \
  $(find out/ -type f -name "signing_key.pem") \
  $(find out/ -type f -name "signing_key.x509") {} \;
