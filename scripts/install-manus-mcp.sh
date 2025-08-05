#!/bin/bash

# Manus MCP Server Installation Script

set -e

echo "Installing Manus MCP Server..."

# Create MCP servers directory
MCP_DIR="$HOME/.local/share/mcp-servers/manus-mcp"
mkdir -p "$MCP_DIR"

# Clone the repository
if [ -d "$MCP_DIR/.git" ]; then
    echo "Updating existing Manus MCP installation..."
    cd "$MCP_DIR"
    git pull
else
    echo "Cloning Manus MCP repository..."
    git clone https://github.com/huyouare/manus-mcp.git "$MCP_DIR"
    cd "$MCP_DIR"
fi

# Check if uv is installed, install if not
if ! command -v uv &> /dev/null; then
    echo "Installing uv (Python package manager)..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    source $HOME/.cargo/env
fi

# Create virtual environment and install dependencies
echo "Setting up Python virtual environment..."
uv venv

# Activate virtual environment and install
echo "Installing Manus MCP dependencies..."
source .venv/bin/activate
uv pip install -e .

# Create sandbox directory
SANDBOX_DIR="$HOME/manus-sandbox"
mkdir -p "$SANDBOX_DIR"

# Verify installation
if [ -f "mcp_server.py" ]; then
    echo "✅ Manus MCP installed successfully"
    echo "📍 Location: $MCP_DIR"
    echo "📁 Sandbox: $SANDBOX_DIR"
else
    echo "❌ Installation failed - mcp_server.py not found"
    exit 1
fi

