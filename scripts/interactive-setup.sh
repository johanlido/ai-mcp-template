#!/bin/bash

# AI MCP Template Interactive Setup Wizard
# This script provides guided installation for all platforms

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Unicode symbols
CHECK="✅"
CROSS="❌"
ARROW="➜"
ROCKET="🚀"
GEAR="⚙️"
LOCK="🔒"

echo -e "${CYAN}${ROCKET} AI MCP Template Setup Wizard${NC}"
echo -e "${CYAN}===============================${NC}"
echo ""

# Detect platform
detect_platform() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        PLATFORM="macos"
        echo -e "${BLUE}📱 Detected: macOS${NC}"
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "win32" || "$OSTYPE" == "cygwin" ]]; then
        PLATFORM="windows"
        echo -e "${BLUE}🪟 Detected: Windows${NC}"
    else
        PLATFORM="linux"
        echo -e "${BLUE}🐧 Detected: Linux${NC}"
    fi
    echo ""
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Validate prerequisites
validate_prerequisites() {
    echo -e "${YELLOW}${GEAR} Checking prerequisites...${NC}"
    local all_good=true
    
    # Check Node.js
    if command_exists node; then
        NODE_VERSION=$(node --version | sed 's/v//')
        MAJOR_VERSION=$(echo $NODE_VERSION | cut -d. -f1)
        if [ "$MAJOR_VERSION" -ge 18 ]; then
            echo -e "${GREEN}${CHECK} Node.js: $NODE_VERSION${NC}"
        else
            echo -e "${RED}${CROSS} Node.js: $NODE_VERSION (requires 18+)${NC}"
            all_good=false
        fi
    else
        echo -e "${RED}${CROSS} Node.js: Not installed${NC}"
        all_good=false
    fi
    
    # Check Python
    if command_exists python3; then
        PYTHON_VERSION=$(python3 --version | awk '{print $2}')
        echo -e "${GREEN}${CHECK} Python: $PYTHON_VERSION${NC}"
    else
        echo -e "${RED}${CROSS} Python 3: Not installed${NC}"
        all_good=false
    fi
    
    # Check Git
    if command_exists git; then
        GIT_VERSION=$(git --version | awk '{print $3}')
        echo -e "${GREEN}${CHECK} Git: $GIT_VERSION${NC}"
    else
        echo -e "${RED}${CROSS} Git: Not installed${NC}"
        all_good=false
    fi
    
    # Check VSCode
    if command_exists code; then
        echo -e "${GREEN}${CHECK} VSCode: Installed${NC}"
    else
        echo -e "${YELLOW}⚠️  VSCode: Not found in PATH${NC}"
    fi
    
    # Check Claude Desktop (platform-specific)
    case $PLATFORM in
        "macos")
            if [ -d "/Applications/Claude.app" ]; then
                echo -e "${GREEN}${CHECK} Claude Desktop: Installed${NC}"
            else
                echo -e "${YELLOW}⚠️  Claude Desktop: Not found${NC}"
            fi
            ;;
        "windows")
            # Windows check would go here
            echo -e "${YELLOW}⚠️  Claude Desktop: Please verify installation manually${NC}"
            ;;
        "linux")
            echo -e "${YELLOW}⚠️  Claude Desktop: Use web version${NC}"
            ;;
    esac
    
    echo ""
    
    if [ "$all_good" = false ]; then
        echo -e "${RED}${CROSS} Some prerequisites are missing. Please install them first.${NC}"
        echo -e "${BLUE}${ARROW} See docs/getting-started/setup-$PLATFORM.md for installation instructions${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}${CHECK} All prerequisites validated!${NC}"
    echo ""
}

# Choose AI stack components
choose_ai_stack() {
    echo -e "${PURPLE}🎯 Choose Your AI Stack Components${NC}"
    echo ""
    
    # Research & Documentation
    echo -e "${CYAN}Research & Documentation:${NC}"
    read -p "$(echo -e "${ARROW} Install Perplexity MCP (web search, research)? [Y/n]: ")" -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        INSTALL_PERPLEXITY=false
    else
        INSTALL_PERPLEXITY=true
    fi
    
    # Development & Automation
    echo -e "${CYAN}Development & Automation:${NC}"
    read -p "$(echo -e "${ARROW} Install Manus MCP (browser automation, code execution)? [Y/n]: ")" -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        INSTALL_MANUS=false
    else
        INSTALL_MANUS=true
    fi
    
    # Design & Frontend
    echo -e "${CYAN}Design & Frontend:${NC}"
    read -p "$(echo -e "${ARROW} Install Figma MCP (design-to-code)? [y/N]: ")" -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        INSTALL_FIGMA=true
    else
        INSTALL_FIGMA=false
    fi
    
    echo ""
}

# Setup environment variables
setup_environment() {
    echo -e "${YELLOW}${LOCK} Setting up environment variables...${NC}"
    
    if [ ! -f .env ]; then
        cp .env.example .env
        echo -e "${GREEN}${CHECK} Created .env file from template${NC}"
    else
        echo -e "${YELLOW}⚠️  .env file already exists, skipping...${NC}"
    fi
    
    echo ""
    echo -e "${CYAN}Please configure your API keys in the .env file:${NC}"
    
    if [ "$INSTALL_PERPLEXITY" = true ]; then
        echo -e "${ARROW} PERPLEXITY_API_KEY: Get from https://perplexity.ai/settings/api"
    fi
    
    if [ "$INSTALL_FIGMA" = true ]; then
        echo -e "${ARROW} FIGMA_ACCESS_TOKEN: Get from Figma account settings"
    fi
    
    echo -e "${ARROW} GITHUB_PERSONAL_ACCESS_TOKEN: Optional, for GitHub integration"
    echo ""
    
    read -p "$(echo -e "${ARROW} Open .env file for editing now? [Y/n]: ")" -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        if command_exists code; then
            code .env
        elif command_exists nano; then
            nano .env
        elif command_exists vim; then
            vim .env
        else
            echo -e "${YELLOW}⚠️  Please edit .env manually with your preferred editor${NC}"
        fi
    fi
    
    echo ""
}

# Install MCP servers
install_mcp_servers() {
    echo -e "${YELLOW}${GEAR} Installing MCP servers...${NC}"
    
    # Create MCP servers directory
    mkdir -p ~/.local/share/mcp-servers
    
    if [ "$INSTALL_PERPLEXITY" = true ]; then
        echo -e "${BLUE}${ARROW} Installing Perplexity MCP...${NC}"
        if ./scripts/install-perplexity-mcp.sh; then
            echo -e "${GREEN}${CHECK} Perplexity MCP installed successfully${NC}"
        else
            echo -e "${RED}${CROSS} Failed to install Perplexity MCP${NC}"
        fi
    fi
    
    if [ "$INSTALL_MANUS" = true ]; then
        echo -e "${BLUE}${ARROW} Installing Manus MCP...${NC}"
        if ./scripts/install-manus-mcp.sh; then
            echo -e "${GREEN}${CHECK} Manus MCP installed successfully${NC}"
        else
            echo -e "${RED}${CROSS} Failed to install Manus MCP${NC}"
        fi
    fi
    
    if [ "$INSTALL_FIGMA" = true ]; then
        echo -e "${BLUE}${ARROW} Installing Figma MCP...${NC}"
        if ./scripts/install-figma-mcp.sh; then
            echo -e "${GREEN}${CHECK} Figma MCP installed successfully${NC}"
        else
            echo -e "${RED}${CROSS} Failed to install Figma MCP${NC}"
        fi
    fi
    
    echo ""
}

# Configure Claude Desktop
configure_claude() {
    echo -e "${YELLOW}${GEAR} Configuring Claude Desktop...${NC}"
    
    if ./scripts/configure-claude.sh; then
        echo -e "${GREEN}${CHECK} Claude Desktop configured successfully${NC}"
    else
        echo -e "${RED}${CROSS} Failed to configure Claude Desktop${NC}"
        echo -e "${YELLOW}⚠️  You may need to configure manually${NC}"
    fi
    
    echo ""
}

# Run health check
run_health_check() {
    echo -e "${YELLOW}${GEAR} Running health check...${NC}"
    
    if ./scripts/health-check.sh; then
        echo -e "${GREEN}${CHECK} Health check passed!${NC}"
    else
        echo -e "${YELLOW}⚠️  Some issues detected. Check the output above.${NC}"
    fi
    
    echo ""
}

# Show next steps
show_next_steps() {
    echo -e "${GREEN}${ROCKET} Setup Complete!${NC}"
    echo ""
    echo -e "${CYAN}Next Steps:${NC}"
    echo -e "${ARROW} 1. Launch Claude Desktop and look for the MCP indicator (🔌)"
    echo -e "${ARROW} 2. Test your MCP servers with sample queries"
    echo -e "${ARROW} 3. Open VSCode and verify GitHub Copilot is active"
    echo -e "${ARROW} 4. Explore example workflows in docs/examples/"
    echo ""
    echo -e "${CYAN}Quick Test Commands:${NC}"
    if [ "$INSTALL_PERPLEXITY" = true ]; then
        echo -e "${ARROW} Perplexity: 'Search for the latest React 18 features'"
    fi
    if [ "$INSTALL_MANUS" = true ]; then
        echo -e "${ARROW} Manus: 'Browse to github.com and show trending repositories'"
    fi
    if [ "$INSTALL_FIGMA" = true ]; then
        echo -e "${ARROW} Figma: 'Analyze the design at [figma-url]'"
    fi
    echo ""
    echo -e "${CYAN}Documentation:${NC}"
    echo -e "${ARROW} Setup Guide: docs/getting-started/setup-$PLATFORM.md"
    echo -e "${ARROW} Troubleshooting: docs/troubleshooting.md"
    echo -e "${ARROW} Best Practices: docs/best-practices.md"
    echo ""
    echo -e "${GREEN}Happy coding with AI! 🎉${NC}"
}

# Main execution flow
main() {
    detect_platform
    validate_prerequisites
    choose_ai_stack
    setup_environment
    install_mcp_servers
    configure_claude
    run_health_check
    show_next_steps
}

# Run main function
main "$@"

