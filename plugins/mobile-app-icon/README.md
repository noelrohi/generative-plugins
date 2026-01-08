# Mobile App Icon Plugin

Generate professional mobile app icons using OpenAI or Gemini image generation APIs.

## Installation

This plugin is installed at `~/.claude/plugins/mobile-app-icon/`.

To enable, add to your Claude Code settings or run:
```bash
claude --plugin-dir ~/.claude/plugins/mobile-app-icon
```

## Configuration

Create `~/.claude/plugins/mobile-app-icon/config.json` with your API keys:

```json
{
  "openai_api_key": "sk-...",
  "gemini_api_key": "..."
}
```

Include whichever API keys you want to use.

## Quick Start

Ask Claude to generate app icons:

- "Generate an app icon for a music player"
- "Create an iOS icon with a rocket ship"
- "Make an Android icon in the neon style"

## Features

- **Multiple providers**: OpenAI (gpt-image-1, dall-e-3, dall-e-2) and Google Gemini
- **14 built-in styles**: minimalism, glassy, neon, gradient, pixel, clay, holographic, and more
- **Configurable options**: size, quality, aspect ratio, background transparency
- **Optimized prompts**: Automatically enhances prompts for professional app icon output

See the full usage documentation in `skills/mobile-app-icon/SKILL.md`.
