#!/bin/bash

# Perplexity MCP Server Installation Script

set -e

echo "Installing Perplexity MCP Server..."

# Create MCP servers directory
MCP_DIR="$HOME/.local/share/mcp-servers/perplexity-mcp"
mkdir -p "$MCP_DIR"

# Clone the repository
if [ -d "$MCP_DIR/.git" ]; then
    echo "Updating existing Perplexity MCP installation..."
    cd "$MCP_DIR"
    git pull
else
    echo "Cloning Perplexity MCP repository..."
    git clone https://github.com/jaacob/perplexity-mcp.git "$MCP_DIR"
    cd "$MCP_DIR"
fi

# Install dependencies
echo "Installing Node.js dependencies..."
npm install

# Build the project
echo "Building Perplexity MCP..."
npm run build

# Verify installation
if [ -f "build/index.js" ]; then
    echo "✅ Perplexity MCP installed successfully"
    echo "📍 Location: $MCP_DIR"
else
    echo "❌ Installation failed - build/index.js not found"
    exit 1
fi

