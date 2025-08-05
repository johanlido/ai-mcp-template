# AI MCP Template: Production-Ready AI Development Environment

[![Use this template](https://img.shields.io/badge/Use%20this%20template-2ea44f?style=for-the-badge)](https://github.com/johanlido/ai-mcp-template/generate)
[![Fork this repo](https://img.shields.io/badge/Fork%20this%20repo-blue?style=for-the-badge)](https://github.com/johanlido/ai-mcp-template/fork)

Transform your development workflow with an orchestrated AI ecosystem that delivers **10x faster prototyping** while maintaining enterprise-grade security. This template integrates Claude Desktop, GitHub Copilot, and specialized MCP servers into a unified development experience.

**🚀 Quick Start**: Get running in 15 minutes | **🔧 Enterprise Ready** | **🔒 Security First**

> **🎯 This is a template repository!** Click "Use this template" above to create your own copy, or fork it to contribute improvements.

## ⚡ Immediate Benefits

- **Reduce design-to-code time by 50-80%** with Figma-to-React automation
- **21% faster task completion** through AI-assisted development workflows  
- **Eliminate context switching** between 6+ development tools
- **Enterprise-grade security** with comprehensive API key management
- **Zero-configuration setup** with automated installation scripts

## 🎯 Overview

This repository provides a **production-ready template** for implementing the AI development environment described in the "Professional AI Development Environment Setup Guide" blog post series. It represents the culmination of months of real-world development experience, refined through building everything from civic engagement platforms to enterprise applications.

**What makes this special?** Traditional development environments force you to choose between power and simplicity. This template eliminates that trade-off entirely by creating an orchestrated AI ecosystem where each component excels in its specific domain while contributing to a unified development experience.

### 🌟 **Key Benefits**

- **10x Productivity Gain**: Prototype, iterate, and deploy faster than traditional development workflows
- **Strategic Amplification**: AI handles routine implementation while you focus on architecture and business logic  
- **Professional Grade**: Enterprise-ready with security, monitoring, and team collaboration features
- **Zero Configuration**: Complete setup in minutes with automated scripts and comprehensive documentation
- **Modular Design**: Enable only the AI services you need, customize for your team's specific requirements

### 🏢 **Perfect For**

- **Tech Leaders** who need hands-on understanding of AI-assisted development to guide strategy
- **Development Teams** looking to implement standardized AI workflows across projects
- **Individual Developers** wanting to leverage cutting-edge AI tools professionally
- **Organizations** seeking to accelerate development velocity while maintaining code quality
- **Consultants** who need rapid prototyping and client demonstration capabilities

This isn't just another tutorial - it's the **blueprint for the future of professional software development**, where AI amplifies human creativity rather than replacing strategic thinking.

## 💻 System Requirements

| Component | macOS | Windows | Linux |
|-----------|-------|---------|-------|
| **Minimum RAM** | 8GB | 8GB | 8GB |
| **Recommended RAM** | 16GB+ | 16GB+ | 16GB+ |
| **Storage** | 5GB free | 5GB free | 5GB free |
| **Claude Desktop** | ✅ Native | ✅ Native | ⚠️ Web only |
| **MCP Servers** | ✅ Full support | ✅ Full support | ✅ Full support |

### 📋 Pre-Installation Checklist

- [ ] **API Keys ready**: Claude, Perplexity, GitHub (optional: Figma)
- [ ] **Development tools installed**: Node.js 18+, Python 3.9+, Git
- [ ] **VSCode** with GitHub Copilot extension
- [ ] **30 minutes available** for setup process
- [ ] **Stable internet connection** (500MB+ downloads)

## 🏗️ Architecture

The environment consists of four integrated layers:

- **Foundation Layer**: VSCode + GitHub Copilot for real-time coding assistance
- **Orchestration Layer**: Claude Desktop with MCP server coordination
- **Intelligence Layer**: Specialized MCP servers for different domains
- **Integration Layer**: Design-to-development workflow bridges

### Included MCP Servers

- **Perplexity MCP**: Real-time web research and documentation
- **Manus MCP**: Web browsing, code execution, and shell commands
- **Figma MCP**: Design-to-development workflow integration

## 🚀 Getting Started

### Step 1: Create Your Own Repository

**Option A: Use as Template (Recommended)**
1. Click the "Use this template" button above
2. Create a new repository in your GitHub account
3. Clone your new repository locally

**Option B: Fork the Repository**
1. Click the "Fork" button above
2. Clone your forked repository locally

### Step 2: Quick Setup

**Interactive Setup (Recommended)**
```bash
# Navigate to your cloned repository
cd your-ai-mcp-template

# Run the interactive setup wizard
./scripts/interactive-setup.sh
```

The interactive setup will:
- ✅ Validate prerequisites
- ✅ Let you choose which MCP servers to install
- ✅ Configure environment variables
- ✅ Set up Claude Desktop integration
- ✅ Run health checks

**Manual Setup (Advanced Users)**
```bash
# Configure environment
cp .env.example .env
# Edit .env with your API keys

# Install all MCP servers
./scripts/install-mcp-servers.sh

# Configure Claude Desktop
./scripts/configure-claude.sh

# Verify installation
./scripts/health-check.sh
```

### Step 3: Platform-Specific Guides

- **📱 macOS**: [Complete macOS Setup Guide](docs/getting-started/setup-macos.md)
- **🪟 Windows**: [Windows Setup Guide](docs/setup-guide.md) (Universal setup guide)
- **🐧 Linux**: [Linux Setup Guide](docs/setup-guide.md) (Universal setup guide)

### Step 4: Verify Installation

1. **Launch Claude Desktop** and look for the MCP indicator (🔌)
2. **Test MCP servers** with sample queries:
   - Perplexity: "Search for the latest React 18 features"
   - Manus: "Browse to github.com and show trending repositories"
3. **Open VSCode** and verify GitHub Copilot is active
4. **Run health check**: `./scripts/health-check.sh`

🎉 **You're ready to start AI-assisted development!**

## 📁 Repository Structure

```
ai-mcp-template/
├── configs/                     # Configuration templates
│   ├── claude-desktop/          # Claude Desktop configurations
│   ├── vscode/                  # VSCode settings and extensions
│   └── mcp-servers/             # Individual MCP server configs
├── scripts/                     # Setup and installation scripts
│   ├── interactive-setup.sh     # Guided setup wizard
│   ├── install-*-mcp.sh        # Individual MCP server installers
│   ├── health-check.sh         # System validation
│   └── configure-claude.sh     # Claude Desktop configuration
├── docs/                        # Comprehensive documentation
│   ├── getting-started/         # Platform-specific setup guides
│   │   └── setup-macos.md      # macOS installation guide
│   ├── guides/                  # Usage and configuration guides
│   │   └── troubleshooting.md  # Comprehensive troubleshooting
│   ├── examples/                # Example workflows and configurations
│   │   └── workflows/          # Step-by-step development workflows
│   │       ├── frontend-development.md    # Frontend workflow
│   │       └── backend-authentication.md  # Backend workflow
│   ├── setup-guide.md          # Universal setup guide
│   ├── troubleshooting.md      # Main troubleshooting guide
│   └── best-practices.md       # Professional usage patterns
├── copilot-instructions.md      # AI agent guardrails and standards
├── .env.example                 # Environment variables template
└── README.md                    # This file
```

## 🔧 Configuration

### Environment Variables

Copy `.env.example` to `.env` and configure:

```bash
# Perplexity API
PERPLEXITY_API_KEY=your_perplexity_api_key_here

# Optional: Manus Configuration
MANUS_SANDBOX_DIR=~/manus-sandbox
MANUS_GLOBAL_TIMEOUT=60

# Optional: Figma Configuration
FIGMA_ACCESS_TOKEN=your_figma_token_here
```

### Claude Desktop Setup

The setup script automatically configures Claude Desktop with all MCP servers. Manual configuration details are available in the setup guide.

### VSCode Configuration

Recommended extensions and settings are automatically applied. See `configs/vscode/` for details.

## 📚 Documentation

### 🚀 Getting Started
- [**macOS Setup Guide**](docs/getting-started/setup-macos.md) - Complete macOS installation
- [**Universal Setup Guide**](docs/setup-guide.md) - Windows and Linux instructions
- [**Troubleshooting Guide**](docs/troubleshooting.md) - Common issues and solutions

### 📖 Usage Guides
- [**Comprehensive Troubleshooting**](docs/guides/troubleshooting.md) - Solve common issues
- [**Team Customization Guide**](TEMPLATE_CUSTOMIZATION.md) - Adapt for your team
- [**Best Practices**](docs/best-practices.md) - Professional usage patterns

### 💡 Example Workflows
- [**Frontend Development**](docs/examples/workflows/frontend-development.md) - React dashboard with AI
- [**Backend Authentication**](docs/examples/workflows/backend-authentication.md) - Secure auth system

### 🤖 AI Guidelines
- [**AI Agent Instructions**](copilot-instructions.md) - Guardrails and standards for AI-generated code

## 🔒 Security

- API keys are managed through environment variables
- Configuration files use placeholders for sensitive data
- Setup scripts include security validation
- See [Best Practices Guide](docs/best-practices.md) for complete details

## 🎯 Usage Examples

### Basic Research Workflow
```
Ask Claude: "Search for the latest React 18 performance optimizations"
→ Perplexity MCP provides current research
→ Manus MCP can test code examples
→ Results integrated in development context
```

### Design-to-Code Workflow
```
1. Select Figma component
2. Ask Claude: "Implement this design with Tailwind CSS"
3. Figma MCP extracts design specifications
4. Claude generates pixel-perfect code
```

## 🛠️ Customization

### Adding New MCP Servers

1. Create configuration in `configs/mcp-servers/new-server/`
2. Add installation script in `scripts/install-new-server.sh`
3. Update Claude Desktop configuration
4. Document in the main README.md

### Team Deployment

- Use `scripts/team-setup.sh` for standardized team configurations
- Customize `configs/` for organizational requirements
- Implement CI/CD with `scripts/validate-config.sh`

## 📊 Performance Optimization

- **Resource Management**: Monitor CPU/RAM usage with included scripts
- **Server Selection**: Enable/disable MCP servers based on project needs
- **Network Optimization**: Configure for corporate environments

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Test with `scripts/validate-setup.sh`
4. Submit a pull request

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

## 🆘 Support

- [Troubleshooting Guide](docs/troubleshooting.md)
- [GitHub Issues](https://github.com/johanlido/ai-mcp-template/issues)
- [Documentation](docs/)

## 🔗 Related Resources

- [VSCode GitHub Copilot Documentation](https://code.visualstudio.com/docs/copilot/setup)
- [Model Context Protocol Specification](https://modelcontextprotocol.io/)
- [Claude Desktop MCP Guide](https://support.anthropic.com/en/articles/10949351-getting-started-with-local-mcp-servers-on-claude-desktop)

---

**Built for professional AI-assisted development workflows**

*This template implements the setup described in the "Professional AI Development Environment Setup Guide" blog post series.*

