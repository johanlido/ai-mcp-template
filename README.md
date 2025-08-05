# 🛠️ Professional AI Development Environment Template

[![Use this template](https://img.shields.io/badge/Use%20this%20template-2ea44f?style=for-the-badge)](https://github.com/johanlido/ai-mcp-template/generate)
[![Fork this repo](https://img.shields.io/badge/Fork%20this%20repo-blue?style=for-the-badge)](https://github.com/johanlido/ai-mcp-template/fork)

A complete setup template for building a professional AI development environment with VSCode, GitHub Copilot, and MCP servers orchestrated through Claude Desktop.

> **🎯 This is a template repository!** Click "Use this template" above to create your own copy, or fork it to contribute improvements.

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

## 🚀 Getting Started (For Template Users)

### Step 1: Create Your Own Repository

**Option A: Use as Template (Recommended)**
1. Click the "Use this template" button above
2. Create a new repository in your GitHub account
3. Clone your new repository locally

**Option B: Fork the Repository**
1. Click the "Fork" button above
2. Clone your forked repository locally

### Step 2: Customize for Your Environment

1. **Update repository information**:
   ```bash
   # Edit these files with your information:
   # - README.md (update repository URLs and names)
   # - package.json (if you add one)
   # - Any references to 'johanlido/ai-mcp-template'
   ```

2. **Configure your environment**:
   ```bash
   cp .env.example .env
   # Edit .env with your API keys and preferences
   ```

3. **Run the setup script**:
   ```bash
   # macOS/Linux
   ./scripts/setup.sh
   
   # Windows
   .\scripts\setup.bat
   ```

### Step 3: Install and Configure

1. **Install MCP servers**:
   ```bash
   ./scripts/install-mcp-servers.sh
   ```

2. **Configure Claude Desktop**:
   ```bash
   ./scripts/configure-claude.sh
   ```

3. **Set up VSCode**:
   ```bash
   ./scripts/configure-vscode.sh
   ```

## 📁 Repository Structure

```
ai-mcp-template/
├── configs/                     # Configuration templates
│   ├── claude-desktop/          # Claude Desktop configurations
│   ├── vscode/                  # VSCode settings and extensions
│   └── mcp-servers/             # Individual MCP server configs
├── scripts/                     # Setup and installation scripts
├── docs/                        # Comprehensive documentation
├── examples/                    # Example configurations and workflows
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

The setup script automatically configures Claude Desktop with all MCP servers. Manual configuration details are available in `docs/claude-desktop-setup.md`.

### VSCode Configuration

Recommended extensions and settings are automatically applied. See `configs/vscode/` for details.

## 📚 Documentation

- [**Complete Setup Guide**](docs/setup-guide.md) - Step-by-step installation
- [**MCP Server Configuration**](docs/mcp-servers.md) - Individual server setup
- [**Troubleshooting Guide**](docs/troubleshooting.md) - Common issues and solutions
- [**Best Practices**](docs/best-practices.md) - Professional usage patterns
- [**Security Guidelines**](docs/security.md) - API key management and security
- [**AI Agent Instructions**](copilot-instructions.md) - Guardrails and standards for AI-generated code

## 🔒 Security

- API keys are managed through environment variables
- Configuration files use placeholders for sensitive data
- Setup scripts include security validation
- See [Security Guidelines](docs/security.md) for complete details

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
4. Document in `docs/mcp-servers.md`

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

