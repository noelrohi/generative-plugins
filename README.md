# Generative Plugins

A marketplace of AI-powered generative plugins for Claude Code.

## Available Plugins

| Plugin | Description | Category |
|--------|-------------|----------|
| [mobile-app-icon](plugins/mobile-app-icon) | Generate mobile app icons using OpenAI or Gemini | Design |

## Installation

### Single Plugin

To use a specific plugin, run Claude Code with the plugin directory:

```bash
claude --plugin-dir /path/to/generative-plugins/plugins/mobile-app-icon
```

### All Plugins

To use all plugins, point to each plugin directory or symlink them to `~/.claude/plugins/`.

## Plugin Structure

Each plugin follows Claude Code's plugin conventions:

```
plugins/
└── plugin-name/
    ├── .claude-plugin/
    │   └── plugin.json      # Plugin manifest
    ├── skills/              # Auto-activated skills
    ├── commands/            # Slash commands
    ├── agents/              # Specialized agents
    ├── hooks/               # Event handlers
    └── scripts/             # Helper scripts
```

## Contributing

To add a new plugin:

1. Create your plugin in `plugins/your-plugin-name/`
2. Follow the plugin structure conventions
3. Add an entry to `marketplace.json`
4. Submit a pull request

## License

MIT
