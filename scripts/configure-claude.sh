#!/bin/bash

# Claude Desktop Configuration Script
# Configures Claude Desktop with MCP servers

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

# Detect OS and set Claude config path
detect_claude_config_path() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        CLAUDE_CONFIG_DIR="$HOME/Library/Application Support/Claude"
        OS="macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        CLAUDE_CONFIG_DIR="$HOME/.config/Claude"
        OS="linux"
    else
        log_error "Unsupported operating system: $OSTYPE"
        exit 1
    fi
    
    CLAUDE_CONFIG_FILE="$CLAUDE_CONFIG_DIR/claude_desktop_config.json"
}

# Check if Claude Desktop is installed
check_claude_installation() {
    log_info "Checking Claude Desktop installation..."
    
    if [[ "$OS" == "macos" ]]; then
        if [ ! -d "/Applications/Claude.app" ]; then
            log_warning "Claude Desktop not found in /Applications/"
            log_info "Please install Claude Desktop from: https://claude.ai/download"
            read -p "Continue anyway? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 0
            fi
        else
            log_success "Claude Desktop found"
        fi
    else
        log_info "Linux detected - please ensure Claude Desktop is installed"
    fi
}

# Load environment variables
load_environment() {
    if [ -f ".env" ]; then
        log_info "Loading environment variables from .env..."
        source .env
    else
        log_warning "No .env file found, using default values"
    fi
}

# Create Claude config directory
create_config_directory() {
    log_info "Creating Claude configuration directory..."
    mkdir -p "$CLAUDE_CONFIG_DIR"
    log_success "Configuration directory ready: $CLAUDE_CONFIG_DIR"
}

# Backup existing configuration
backup_existing_config() {
    if [ -f "$CLAUDE_CONFIG_FILE" ]; then
        local backup_file="$CLAUDE_CONFIG_FILE.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Backing up existing configuration to: $backup_file"
        cp "$CLAUDE_CONFIG_FILE" "$backup_file"
        log_success "Existing configuration backed up"
    fi
}

# Generate Claude Desktop configuration
generate_claude_config() {
    log_info "Generating Claude Desktop configuration..."
    
    # Get the absolute path to MCP servers
    local mcp_dir="$HOME/.local/share/mcp-servers"
    local user_home="$HOME"
    
    # Substitute environment variables with actual values or defaults
    local perplexity_api_key="${PERPLEXITY_API_KEY:-your_perplexity_api_key_here}"
    local perplexity_model="${PERPLEXITY_MODEL:-sonar}"
    local manus_sandbox_dir="${MANUS_SANDBOX_DIR:-~/manus-sandbox}"
    local manus_timeout="${MANUS_GLOBAL_TIMEOUT:-60}"
    local manus_headless="${MANUS_BROWSER_HEADLESS:-false}"
    local manus_search_results="${MANUS_GOOGLE_SEARCH_MAX_RESULTS:-10}"
    local manus_log_level="${MANUS_LOG_LEVEL:-INFO}"
    local github_token="${GITHUB_PERSONAL_ACCESS_TOKEN:-your_github_token_here}"
    local brave_api_key="${BRAVE_API_KEY:-your_brave_api_key_here}"
    
    # Create the configuration
    cat > "$CLAUDE_CONFIG_FILE" << EOF
{
  "mcpServers": {
    "perplexity-server": {
      "command": "node",
      "args": [
        "$mcp_dir/perplexity-mcp/build/index.js"
      ],
      "env": {
        "PERPLEXITY_API_KEY": "$perplexity_api_key",
        "PERPLEXITY_MODEL": "$perplexity_model"
      }
    },
    "manus-mcp": {
      "command": "uv",
      "args": [
        "--directory",
        "$mcp_dir/manus-mcp",
        "run",
        "mcp_server.py"
      ],
      "env": {
        "SANDBOX_DIR": "$manus_sandbox_dir",
        "GLOBAL_TIMEOUT": "$manus_timeout",
        "BROWSER_HEADLESS": "$manus_headless",
        "GOOGLE_SEARCH_MAX_RESULTS": "$manus_search_results",
        "LOG_LEVEL": "$manus_log_level"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-filesystem",
        "$user_home/Desktop",
        "$user_home/Downloads",
        "$user_home/Documents"
      ]
    }
EOF

    # Add GitHub server if token is configured
    if [ "$github_token" != "your_github_token_here" ] && [ -n "$github_token" ]; then
        cat >> "$CLAUDE_CONFIG_FILE" << EOF
    ,
    "github": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-github"
      ],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "$github_token"
      }
    }
EOF
    fi

    # Add Brave Search server if API key is configured
    if [ "$brave_api_key" != "your_brave_api_key_here" ] && [ -n "$brave_api_key" ]; then
        cat >> "$CLAUDE_CONFIG_FILE" << EOF
    ,
    "brave-search": {
      "command": "npx",
      "args": [
        "-y",
        "@modelcontextprotocol/server-brave-search"
      ],
      "env": {
        "BRAVE_API_KEY": "$brave_api_key"
      }
    }
EOF
    fi

    # Close the configuration
    cat >> "$CLAUDE_CONFIG_FILE" << EOF
  }
}
EOF

    log_success "Claude Desktop configuration generated"
}

# Validate configuration
validate_config() {
    log_info "Validating configuration..."
    
    # Check if the config file is valid JSON
    if command -v python3 &> /dev/null; then
        if python3 -m json.tool "$CLAUDE_CONFIG_FILE" > /dev/null 2>&1; then
            log_success "Configuration is valid JSON"
        else
            log_error "Configuration is not valid JSON"
            return 1
        fi
    elif command -v jq &> /dev/null; then
        if jq empty "$CLAUDE_CONFIG_FILE" > /dev/null 2>&1; then
            log_success "Configuration is valid JSON"
        else
            log_error "Configuration is not valid JSON"
            return 1
        fi
    else
        log_warning "Cannot validate JSON (python3 or jq not available)"
    fi
    
    # Check if MCP server files exist
    local mcp_dir="$HOME/.local/share/mcp-servers"
    
    if [ -f "$mcp_dir/perplexity-mcp/build/index.js" ]; then
        log_success "Perplexity MCP server found"
    else
        log_warning "Perplexity MCP server not found at expected location"
    fi
    
    if [ -f "$mcp_dir/manus-mcp/mcp_server.py" ]; then
        log_success "Manus MCP server found"
    else
        log_warning "Manus MCP server not found at expected location"
    fi
}

# Create Figma MCP configuration note
create_figma_note() {
    log_info "Creating Figma MCP setup note..."
    
    cat > "$CLAUDE_CONFIG_DIR/figma_mcp_setup.md" << EOF
# Figma MCP Server Setup

The Figma MCP server requires manual setup within the Figma desktop application.

## Setup Steps:

1. **Install Figma Desktop App**
   - Download from: https://www.figma.com/downloads/
   - Ensure you have the latest version

2. **Enable MCP Server in Figma**
   - Open Figma desktop app
   - Go to Figma menu → Preferences
   - Enable "Dev Mode MCP Server"
   - Server will run at: http://127.0.0.1:3845/mcp

3. **Configure Your MCP Client**
   - The server runs locally and doesn't need Claude Desktop configuration
   - Configure your IDE (VS Code, Cursor, etc.) to connect to the Figma server

## Requirements:
- Dev or Full seat on Professional, Organization, or Enterprise plans
- Figma desktop application (not web version)
- Compatible MCP client (VS Code with GitHub Copilot, Cursor, Windsurf, Claude Code)

## Usage:
- Select frames/components in Figma
- Ask your AI assistant to implement the selected design
- Or copy Figma URLs and include them in prompts
EOF

    log_success "Figma MCP setup guide created at: $CLAUDE_CONFIG_DIR/figma_mcp_setup.md"
}

# Display next steps
show_next_steps() {
    echo
    log_success "Claude Desktop configuration completed!"
    echo
    log_info "Configuration file: $CLAUDE_CONFIG_FILE"
    echo
    log_info "Next steps:"
    log_info "1. Restart Claude Desktop to load the new configuration"
    log_info "2. Look for the MCP server indicator (🔌) in Claude Desktop"
    log_info "3. Click the indicator to see available tools"
    echo
    log_info "Configured MCP servers:"
    log_info "  - Perplexity (web search and research)"
    log_info "  - Manus (web browsing, code execution, shell)"
    log_info "  - Filesystem (file system access)"
    
    if [ "${GITHUB_PERSONAL_ACCESS_TOKEN:-}" != "your_github_token_here" ] && [ -n "${GITHUB_PERSONAL_ACCESS_TOKEN:-}" ]; then
        log_info "  - GitHub (repository integration)"
    fi
    
    if [ "${BRAVE_API_KEY:-}" != "your_brave_api_key_here" ] && [ -n "${BRAVE_API_KEY:-}" ]; then
        log_info "  - Brave Search (web search)"
    fi
    
    echo
    log_info "For Figma MCP setup, see: $CLAUDE_CONFIG_DIR/figma_mcp_setup.md"
    echo
    log_warning "If servers don't appear, check that:"
    log_warning "  - API keys are correctly set in .env file"
    log_warning "  - MCP servers are installed (run ./scripts/install-mcp-servers.sh)"
    log_warning "  - Claude Desktop has been restarted"
    echo
}

# Main configuration function
main() {
    echo "=================================================="
    echo "Claude Desktop Configuration"
    echo "=================================================="
    echo
    
    detect_claude_config_path
    check_claude_installation
    load_environment
    create_config_directory
    backup_existing_config
    generate_claude_config
    validate_config
    create_figma_note
    show_next_steps
}

# Run main function
main "$@"

