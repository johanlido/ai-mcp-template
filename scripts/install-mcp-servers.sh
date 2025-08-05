#!/bin/bash

# MCP Servers Installation Script
# Installs and configures all MCP servers for the AI development environment

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Installation directory
MCP_DIR="$HOME/.local/share/mcp-servers"

# Install Perplexity MCP Server
install_perplexity_mcp() {
    log_info "Installing Perplexity MCP Server..."
    
    cd "$MCP_DIR"
    
    # Check if already installed
    if [ -d "perplexity-mcp" ]; then
        log_info "Perplexity MCP already exists, updating..."
        cd perplexity-mcp
        git pull
    else
        log_info "Cloning Perplexity MCP repository..."
        git clone https://github.com/jaacob/perplexity-mcp.git
        cd perplexity-mcp
    fi
    
    # Install dependencies and build
    log_info "Installing dependencies..."
    npm install
    
    log_info "Building server..."
    npm run build
    
    log_success "Perplexity MCP Server installed"
}

# Install Manus MCP Server
install_manus_mcp() {
    log_info "Installing Manus MCP Server..."
    
    cd "$MCP_DIR"
    
    # Check if already installed
    if [ -d "manus-mcp" ]; then
        log_info "Manus MCP already exists, updating..."
        cd manus-mcp
        git pull
    else
        log_info "Cloning Manus MCP repository..."
        git clone https://github.com/huyouare/manus-mcp.git
        cd manus-mcp
    fi
    
    # Install dependencies
    log_info "Setting up Python environment..."
    
    # Check if uv is available
    if command -v uv &> /dev/null; then
        uv venv
        source .venv/bin/activate
        uv pip install -e .
    else
        python3 -m venv .venv
        source .venv/bin/activate
        pip install -e .
    fi
    
    log_success "Manus MCP Server installed"
}

# Install additional MCP servers
install_additional_servers() {
    log_info "Installing additional MCP servers..."
    
    # Filesystem server (via npm)
    log_info "Installing Filesystem MCP server..."
    npm install -g @modelcontextprotocol/server-filesystem
    
    # GitHub server (via npm)
    log_info "Installing GitHub MCP server..."
    npm install -g @modelcontextprotocol/server-github
    
    # Brave Search server (via npm)
    log_info "Installing Brave Search MCP server..."
    npm install -g @modelcontextprotocol/server-brave-search
    
    log_success "Additional MCP servers installed"
}

# Install Perplexity via Smithery (alternative method)
install_perplexity_smithery() {
    log_info "Installing Perplexity MCP via Smithery..."
    
    if command -v smithery &> /dev/null; then
        npx -y @smithery/cli install @jaacob/perplexity-mcp --client claude
        log_success "Perplexity MCP installed via Smithery"
    else
        log_warning "Smithery not available, using manual installation"
        install_perplexity_mcp
    fi
}

# Verify installations
verify_installations() {
    log_info "Verifying MCP server installations..."
    
    local errors=0
    
    # Check Perplexity
    if [ -f "$MCP_DIR/perplexity-mcp/build/index.js" ]; then
        log_success "Perplexity MCP: ✓"
    else
        log_error "Perplexity MCP: ✗"
        errors=$((errors + 1))
    fi
    
    # Check Manus
    if [ -f "$MCP_DIR/manus-mcp/mcp_server.py" ]; then
        log_success "Manus MCP: ✓"
    else
        log_error "Manus MCP: ✗"
        errors=$((errors + 1))
    fi
    
    # Check npm packages
    if npm list -g @modelcontextprotocol/server-filesystem &> /dev/null; then
        log_success "Filesystem MCP: ✓"
    else
        log_error "Filesystem MCP: ✗"
        errors=$((errors + 1))
    fi
    
    if [ $errors -eq 0 ]; then
        log_success "All MCP servers verified successfully"
    else
        log_error "$errors MCP server(s) failed verification"
        return 1
    fi
}

# Create server configuration templates
create_config_templates() {
    log_info "Creating configuration templates..."
    
    # Create individual server configs
    mkdir -p "$HOME/.config/ai-dev-env/mcp-configs"
    
    # Perplexity config
    cat > "$HOME/.config/ai-dev-env/mcp-configs/perplexity.json" << EOF
{
  "perplexity-server": {
    "command": "node",
    "args": [
      "$MCP_DIR/perplexity-mcp/build/index.js"
    ],
    "env": {
      "PERPLEXITY_API_KEY": "\${PERPLEXITY_API_KEY}",
      "PERPLEXITY_MODEL": "\${PERPLEXITY_MODEL:-sonar}"
    }
  }
}
EOF
    
    # Manus config
    cat > "$HOME/.config/ai-dev-env/mcp-configs/manus.json" << EOF
{
  "manus-mcp": {
    "command": "uv",
    "args": [
      "--directory",
      "$MCP_DIR/manus-mcp",
      "run",
      "mcp_server.py"
    ],
    "env": {
      "SANDBOX_DIR": "\${MANUS_SANDBOX_DIR:-~/manus-sandbox}",
      "GLOBAL_TIMEOUT": "\${MANUS_GLOBAL_TIMEOUT:-60}",
      "BROWSER_HEADLESS": "\${MANUS_BROWSER_HEADLESS:-false}",
      "GOOGLE_SEARCH_MAX_RESULTS": "\${MANUS_GOOGLE_SEARCH_MAX_RESULTS:-10}",
      "LOG_LEVEL": "\${MANUS_LOG_LEVEL:-INFO}"
    }
  }
}
EOF
    
    log_success "Configuration templates created"
}

# Main installation function
main() {
    echo "=================================================="
    echo "MCP Servers Installation"
    echo "=================================================="
    echo
    
    # Create MCP directory
    mkdir -p "$MCP_DIR"
    
    # Install servers
    install_perplexity_mcp
    install_manus_mcp
    install_additional_servers
    
    # Create configurations
    create_config_templates
    
    # Verify installations
    verify_installations
    
    echo
    log_success "MCP servers installation completed!"
    echo
    log_info "Installed servers:"
    log_info "  - Perplexity MCP (web search and research)"
    log_info "  - Manus MCP (web browsing, code execution, shell)"
    log_info "  - Filesystem MCP (file system access)"
    log_info "  - GitHub MCP (GitHub integration)"
    log_info "  - Brave Search MCP (web search)"
    echo
    log_info "Next step: Run ./scripts/configure-claude.sh to configure Claude Desktop"
    echo
}

# Run main function
main "$@"

