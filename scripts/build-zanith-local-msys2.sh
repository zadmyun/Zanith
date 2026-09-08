#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if [[ "${MSYSTEM:-}" != "MINGW64" ]]; then
    echo "This script must run inside an MSYS2 MINGW64 shell." >&2
    exit 1
fi

pacman -S --needed --noconfirm git make unzip zip pactoys
pacboy -S --needed --noconfirm \
    ca-certificates:p cc:p cmake:p curl:p diffutils:p fast_float:p fftw:p hidapi:p \
    json-c:p libevent:p lcms2:p libdovi:p meson:p miniupnpc:p gcc:p nasm:p ninja:p \
    openssl:p opus:p pkgconf:p protobuf:p python:p python-protobuf:p python-psutil:p python-glad:p \
    python-jinja:p python-pip:p qt6-base:p qt6-declarative:p qt6-svg:p shaderc:p \
    speexdsp:p spirv-cross:p vulkan:p vulkan-headers:p compiler-rt:p


./scripts/bootstrap-submodules.sh

# libplacebo revision used by the Canary base.
./scripts/build-libplacebo-windows.sh

if [[ ! -d ffmpeg-n7.1-latest-win64-gpl-shared-7.1 ]]; then
    curl -L -o ffmpeg-n7.1-latest-win64-gpl-shared-7.1.zip \
        https://github.com/streetpea/FFmpeg-Builds/releases/download/latest/ffmpeg-n7.1-latest-win64-gpl-shared-7.1.zip
    unzip -o ffmpeg-n7.1-latest-win64-gpl-shared-7.1.zip
fi
cp -a "ffmpeg-n7.1-latest-win64-gpl-shared-7.1/bin/." /mingw64/bin
cp -a "ffmpeg-n7.1-latest-win64-gpl-shared-7.1/include/." /mingw64/include
cp -a "ffmpeg-n7.1-latest-win64-gpl-shared-7.1/lib/." /mingw64/lib

INSTALL_PREFIX=/mingw64 ./scripts/build-sdl2-compat.sh .
cp /mingw64/lib/pkgconfig/sdl2-compat.pc /mingw64/lib/pkgconfig/sdl2.pc

rm -rf build
cmake -S . -B build -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCHIAKI_ENABLE_CLI=OFF \
    -DCHIAKI_ENABLE_TESTS=OFF
cmake --build build --config Release --target chiaki

rm -rf Zanith-Win
./scripts/deploy-windows-msys2.sh Zanith-Win build/gui/Zanith.exe "$ROOT/build/third-party/cpp-steam-tools" /mingw64 gui/src/qml
cp ZANITH_MODIFICATIONS.md Zanith-Win/
mkdir -p Zanith-Win/licenses
cp LICENSES/AGPL-3.0-only-OpenSSL.txt Zanith-Win/licenses/

echo
echo "Portable build ready: $ROOT/Zanith-Win/Zanith.exe"
echo "Run scripts/build-zanith-local.ps1 from PowerShell to also create the Inno Setup installer."
