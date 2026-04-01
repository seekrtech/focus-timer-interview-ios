#!/bin/bash
set -euo pipefail

echo "=== Interview Environment Bootstrap ==="
echo ""

SWIFT_DIR="/workspace/.swift"
SWIFT_VERSION="6.1-RELEASE"
SWIFT_URL="https://download.swift.org/swift-6.1-release/ubuntu2404/swift-6.1-RELEASE/swift-6.1-RELEASE-ubuntu24.04.tar.gz"

# --- 1. Install Swift 6.1 ---
if [ -x "${SWIFT_DIR}/usr/bin/swift" ]; then
    echo "[1/2] Swift already installed, skipping."
else
    echo "[1/2] Installing Swift 6.1..."

    # Install system dependencies needed by Swift on Linux
    sudo apt-get update -qq
    sudo apt-get install -y -qq \
        binutils \
        git \
        curl \
        libcurl4-openssl-dev \
        libxml2-dev \
        libncurses6 \
        libz3-dev \
        > /dev/null 2>&1

    curl -fsSL "${SWIFT_URL}" | tar xz -C /workspace
    mv "/workspace/swift-${SWIFT_VERSION}-ubuntu24.04" "${SWIFT_DIR}"
    echo "Swift installed to ${SWIFT_DIR}"
fi

# --- Persist env to PVC so it survives pod restarts ---
ENV_FILE="/workspace/.interview-env"
cat > "${ENV_FILE}" <<EOF
export SWIFT_HOME="${SWIFT_DIR}"
export PATH="${SWIFT_DIR}/usr/bin:\$PATH"
EOF

# Hook into .bashrc (will be re-added by pod startup if lost)
ENV_MARKER="# interview-bootstrap"
if ! grep -q "${ENV_MARKER}" ~/.bashrc 2>/dev/null; then
    cat >> ~/.bashrc <<EOF

${ENV_MARKER}
[ -f /workspace/.interview-env ] && source /workspace/.interview-env
EOF
fi
echo "Environment persisted to ${ENV_FILE}"

export SWIFT_HOME="${SWIFT_DIR}"
export PATH="${SWIFT_DIR}/usr/bin:${PATH}"
echo "Swift: $(swift --version 2>&1 | head -1)"
echo ""

# --- 2. Pre-warm SPM cache ---
echo "[2/2] Pre-warming SPM cache..."
swift build
echo ""

echo "=== Bootstrap Complete ==="
echo ""
