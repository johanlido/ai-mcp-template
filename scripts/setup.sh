#!/bin/bash

# Professional AI Development Environment Setup Script
# This script sets up the complete AI development environment from the template

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on supported OS
check_os() {
    log_info "Checking operating system..."
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        log_success "macOS detected"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        log_success "Linux detected"
    else
        log_error "Unsupported operating system: $OSTYPE"
        log_error "This script supports macOS and Linux only"
        exit 1
    fi
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check for required tools
    local missing_tools=()
    
    if ! command -v git &> /dev/null; then
        missing_tools+=("git")
    fi
    
    if ! command -v node &> /dev/null; then
        missing_tools+=("node")
    fi
    
    if ! command -v npm &> /dev/null; then
        missing_tools+=("npm")
    fi
    
    if ! command -v python3 &> /dev/null; then
        missing_tools+=("python3")
    fi
    
    if ! command -v pip3 &> /dev/null; then
        missing_tools+=("pip3")
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_error "Please install the missing tools and run this script again"
        exit 1
    fi
    
    log_success "All prerequisites are installed"
}

# Check hardware requirements
check_hardware() {
    log_info "Checking hardware requirements..."
    
    # Check RAM (macOS and Linux)
    if [[ "$OS" == "macos" ]]; then
        RAM_GB=$(( $(sysctl -n hw.memsize) / 1024 / 1024 / 1024 ))
    else
        RAM_GB=$(( $(grep MemTotal /proc/meminfo | awk '{print $2}') / 1024 / 1024 ))
    fi
    
    if [ "$RAM_GB" -lt 16 ]; then
        log_warning "Your system has ${RAM_GB}GB RAM. 16GB minimum recommended (32GB optimal)"
        log_warning "You may experience performance issues with the AI development environment"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Setup cancelled by user"
            exit 0
        fi
    else
        log_success "RAM check passed: ${RAM_GB}GB available"
    fi
}

# Create environment file from template
setup_environment() {
    log_info "Setting up environment configuration..."
    
    if [ ! -f ".env" ]; then
        if [ -f ".env.example" ]; then
            cp .env.example .env
            log_success "Created .env from template"
            log_warning "Please edit .env file with your API keys before continuing"
            log_info "Required API keys:"
            log_info "  - PERPLEXITY_API_KEY (get from: https://www.perplexity.ai/settings/api)"
            log_info "  - FIGMA_ACCESS_TOKEN (optional, get from: https://www.figma.com/developers/api#access-tokens)"
            log_info "  - GITHUB_PERSONAL_ACCESS_TOKEN (optional, for GitHub MCP server)"
        else
            log_error ".env.example file not found"
            exit 1
        fi
    else
        log_info ".env file already exists, skipping creation"
    fi
}

# Create necessary directories
create_directories() {
    log_info "Creating necessary directories..."
    
    # Create MCP servers directory
    mkdir -p ~/.local/share/mcp-servers
    
    # Create backup directory
    mkdir -p ~/.config/ai-dev-env/backups
    
    # Create logs directory
    mkdir -p ~/.config/ai-dev-env/logs
    
    log_success "Directories created"
}

# Backup existing configurations
backup_configs() {
    log_info "Backing up existing configurations..."
    
    local backup_dir="$HOME/.config/ai-dev-env/backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    # Backup Claude Desktop config
    if [[ "$OS" == "macos" ]]; then
        local claude_config="$HOME/Library/Application Support/Claude/claude_desktop_config.json"
    else
        local claude_config="$HOME/.config/Claude/claude_desktop_config.json"
    fi
    
    if [ -f "$claude_config" ]; then
        cp "$claude_config" "$backup_dir/claude_desktop_config.json.backup"
        log_success "Backed up Claude Desktop configuration"
    fi
    
    # Backup VSCode settings
    if [[ "$OS" == "macos" ]]; then
        local vscode_settings="$HOME/Library/Application Support/Code/User/settings.json"
    else
        local vscode_settings="$HOME/.config/Code/User/settings.json"
    fi
    
    if [ -f "$vscode_settings" ]; then
        cp "$vscode_settings" "$backup_dir/vscode_settings.json.backup"
        log_success "Backed up VSCode settings"
    fi
    
    log_info "Backups stored in: $backup_dir"
}

# Install Python dependencies
install_python_deps() {
    log_info "Installing Python dependencies..."
    
    # Install uv if not present
    if ! command -v uv &> /dev/null; then
        log_info "Installing uv (fast Python package manager)..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        source $HOME/.cargo/env
    fi
    
    log_success "Python dependencies ready"
}

# Install Node.js dependencies
install_node_deps() {
    log_info "Installing Node.js dependencies..."
    
    # Install global packages needed for MCP servers
    npm install -g @modelcontextprotocol/server-filesystem
    npm install -g @smithery/cli
    
    log_success "Node.js dependencies installed"
}

# Validate API keys
validate_api_keys() {
    log_info "Validating API keys..."
    
    # Source the .env file
    if [ -f ".env" ]; then
        source .env
    else
        log_warning "No .env file found, skipping API key validation"
        return
    fi
    
    # Check Perplexity API key
    if [ -n "$PERPLEXITY_API_KEY" ] && [ "$PERPLEXITY_API_KEY" != "your_perplexity_api_key_here" ]; then
        log_success "Perplexity API key configured"
    else
        log_warning "Perplexity API key not configured"
    fi
    
    # Check other API keys
    if [ -n "$FIGMA_ACCESS_TOKEN" ] && [ "$FIGMA_ACCESS_TOKEN" != "your_figma_access_token_here" ]; then
        log_success "Figma access token configured"
    else
        log_info "Figma access token not configured (optional)"
    fi
}

# Main setup function
main() {
    echo "=================================================="
    echo "Professional AI Development Environment Setup"
    echo "=================================================="
    echo
    
    check_os
    check_prerequisites
    check_hardware
    setup_environment
    create_directories
    backup_configs
    install_python_deps
    install_node_deps
    validate_api_keys
    
    echo
    log_success "Basic setup completed!"
    echo
    log_info "Next steps:"
    log_info "1. Edit .env file with your API keys"
    log_info "2. Run: ./scripts/install-mcp-servers.sh"
    log_info "3. Run: ./scripts/configure-claude.sh"
    log_info "4. Run: ./scripts/configure-vscode.sh"
    echo
    log_info "For detailed instructions, see: docs/setup-guide.md"
    echo
}

# Run main function
main "$@"

