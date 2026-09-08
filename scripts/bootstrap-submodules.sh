#!/usr/bin/env bash
set -euo pipefail

# The GitHub source archive used to create Zanith does not contain gitlink
# metadata. These are the exact Windows-relevant submodule revisions used by
# upstream chiaki-ng commit 6547d8aed03503646fe1043512616e26c03fa9db.
clone_at() {
    local url="$1"
    local path="$2"
    local commit="$3"
    if [[ -f "$path/.zanith-submodule-ready" ]]; then
        return
    fi
    rm -rf "$path"
    git clone "$url" "$path"
    git -C "$path" checkout "$commit"
    touch "$path/.zanith-submodule-ready"
}

clone_at https://github.com/streetpea/cpp-steam-tools.git third-party/cpp-steam-tools d36565f
clone_at https://github.com/curl/curl.git third-party/curl b1ef0e1
clone_at https://github.com/streetpea/gf-complete.git third-party/gf-complete fa54a46
clone_at https://github.com/streetpea/jerasure.git third-party/jerasure 505ccb4
clone_at https://github.com/nanopb/nanopb.git third-party/nanopb cad3c18

echo "Windows submodules are ready."
