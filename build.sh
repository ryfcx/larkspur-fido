#!/usr/bin/env bash
set -euo pipefail

for tool in git cmake arm-none-eabi-gcc; do
  command -v "$tool" >/dev/null || { echo "missing: $tool" >&2; exit 1; }
done

repo_dir=$(cd "$(dirname "$0")" && pwd)
build_dir="$repo_dir/build"
mkdir -p "$build_dir"

if [ ! -d "$build_dir/pico-fido/.git" ]; then
  git clone --quiet --depth 1 --branch v6.6 https://github.com/polhenarejos/pico-fido.git "$build_dir/pico-fido"
fi
git -C "$build_dir/pico-fido" submodule update --init --recursive --depth 1

for patch_target in "pico-fido:pico-fido.patch" "pico-fido/pico-keys-sdk:pico-keys-sdk.patch"; do
  source_dir=${patch_target%%:*}
  patch_file=${patch_target#*:}
  if git -C "$build_dir/$source_dir" apply --check "$repo_dir/patches/$patch_file"; then
    git -C "$build_dir/$source_dir" apply "$repo_dir/patches/$patch_file"
  elif ! git -C "$build_dir/$source_dir" apply --reverse --check "$repo_dir/patches/$patch_file"; then
    echo "patch failed: $patch_file" >&2
    exit 1
  fi
done

if [ ! -d "$build_dir/pico-sdk/.git" ]; then
  git clone --quiet --depth 1 --branch 2.1.1 https://github.com/raspberrypi/pico-sdk.git "$build_dir/pico-sdk"
fi
git -C "$build_dir/pico-sdk" submodule update --init --recursive --depth 1

cmake -S "$build_dir/pico-fido" -B "$build_dir/out" \
  -DPICO_SDK_PATH="$build_dir/pico-sdk" \
  -DPICO_BOARD=pico \
  -DPICO_FLASH_SIZE_BYTES=16777216 \
  -DCMAKE_BUILD_TYPE=Release
cmake --build "$build_dir/out" --parallel
cp "$build_dir/out/pico_fido.uf2" "$build_dir/larkspur-fido-rp2040.uf2"
echo "built: $build_dir/larkspur-fido-rp2040.uf2"
