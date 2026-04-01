#!/bin/bash
set -euo pipefail

echo "=== Installing AI Coding Tools ==="
echo ""

# --- Ensure Node.js is available ---
if ! command -v node &>/dev/null; then
    echo "Installing Node.js 22..."
    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - > /dev/null 2>&1
    sudo apt-get install -y -qq nodejs > /dev/null 2>&1
fi
echo "Node.js: $(node --version)"
echo ""

# --- 1. Claude Code ---
if command -v claude &>/dev/null; then
    echo "[1/3] Claude Code already installed."
else
    echo "[1/3] Installing Claude Code..."
    npm install -g @anthropic-ai/claude-code
fi

# --- 2. OpenAI Codex ---
if command -v codex &>/dev/null; then
    echo "[2/3] Codex already installed."
else
    echo "[2/3] Installing OpenAI Codex..."
    npm install -g @openai/codex
fi

# --- 3. Gemini CLI ---
if command -v gemini &>/dev/null; then
    echo "[3/3] Gemini CLI already installed."
else
    echo "[3/3] Installing Gemini CLI..."
    npm install -g @google/gemini-cli
fi

echo ""
echo "=== Installation Complete ==="
echo ""
echo "Available tools:"
command -v claude &>/dev/null && echo "  claude   $(claude --version 2>/dev/null || echo '(installed)')"
command -v codex  &>/dev/null && echo "  codex    $(codex --version 2>/dev/null || echo '(installed)')"
command -v gemini &>/dev/null && echo "  gemini   $(gemini --version 2>/dev/null || echo '(installed)')"
echo ""
echo "Each tool requires its own API key or login."
echo "Run the tool name in terminal to start authentication."
echo ""
