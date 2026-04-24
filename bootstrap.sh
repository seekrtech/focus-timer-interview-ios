#!/bin/bash
set -euo pipefail

echo "=== Interview Environment Bootstrap ==="
echo ""

SWIFT_DIR="/workspace/.swift"
SWIFT_VERSION="6.1-RELEASE"
SWIFT_PLATFORM="ubuntu22.04"
SWIFT_URL="https://download.swift.org/swift-6.1-release/ubuntu2204/swift-6.1-RELEASE/swift-6.1-RELEASE-ubuntu22.04.tar.gz"
SWIFT_TGZ="/tmp/swift-${SWIFT_VERSION}.tar.gz"

# --- 1. System dependencies (rootfs-ephemeral — must run every boot) ---
echo "[1/3] Checking system dependencies..."
SYS_DEPS=(binutils git curl libcurl4-openssl-dev libxml2-dev libncurses6 libz3-dev libsqlite3-dev gcc libstdc++-12-dev)

if ldconfig -p | grep -q libncurses.so.6; then
    echo "[1/3] System deps already present, skipping apt."
else
    echo "[1/3] Installing system dependencies..."
    sudo apt-get update -qq
    sudo apt-get install -y -qq "${SYS_DEPS[@]}"
fi

# --- 2. Install Swift (persisted to PVC — skip if binary works) ---
echo "[2/3] Checking Swift..."
if "${SWIFT_DIR}/usr/bin/swift" --version &>/dev/null; then
    echo "[2/3] Swift already installed and working, skipping download."
else
    echo "[2/3] Installing Swift ${SWIFT_VERSION}..."
    rm -f "${SWIFT_TGZ}"
    curl -fL --progress-bar "${SWIFT_URL}" -o "${SWIFT_TGZ}"
    echo "Extracting..."
    tar xzf "${SWIFT_TGZ}" -C /workspace
    rm -f "${SWIFT_TGZ}"
    mv "/workspace/swift-${SWIFT_VERSION}-${SWIFT_PLATFORM}" "${SWIFT_DIR}"
    echo "Swift installed to ${SWIFT_DIR}"
fi

# --- Persist PATH to PVC ---
ENV_FILE="/workspace/.interview-env"
cat > "${ENV_FILE}" <<EOF
export SWIFT_HOME="${SWIFT_DIR}"
export PATH="${SWIFT_DIR}/usr/bin:\$PATH"
EOF

# Hook .bashrc: source env + auto-heal on login if swift broken
MARKER="# interview-bootstrap"
if ! grep -q "${MARKER}" ~/.bashrc 2>/dev/null; then
    cat >> ~/.bashrc <<EOF

${MARKER}
[ -f /workspace/.interview-env ] && source /workspace/.interview-env
if ! command -v swift &>/dev/null || ! swift --version &>/dev/null 2>&1; then
    echo "Swift unavailable — running bootstrap..."
    bash /workspace/project/bootstrap.sh
fi
EOF
fi

export SWIFT_HOME="${SWIFT_DIR}"
export PATH="${SWIFT_DIR}/usr/bin:${PATH}"
echo "Swift: $(swift --version 2>&1 | head -1)"
echo ""

# --- 3. Pre-warm SPM cache ---
echo "[3/3] Pre-warming SPM cache..."
cd "$(dirname "$0")"
swift build
echo ""

echo "=== Bootstrap Complete ==="
echo ""
