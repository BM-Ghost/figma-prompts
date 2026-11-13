# figma-to-native

Turn a Figma component into production-ready **SwiftUI (iOS)** and **Jetpack Compose (Android)** code. Send a link, get a documented, accessible, previewable component, and keep one shared theme file per platform consistent across every component you build.

It ships as a Claude Code plugin (skill plus agent) and as a skill you can upload to Claude chat.

## What you get

For each component and platform:

- one component file named after its primary type, with variants, states, previews, Dark mode, RTL and large-text support
- a shared theme file (`Theme.swift`, `Theme.kt`), created with the first component and extended afterwards, so colours, spacing and type never drift between components
- a short report with a usage example, assumptions, and anything in the design that is not tied to a design-system variable

## Install

### Claude Code, as a plugin (recommended)

```
/plugin marketplace add BM-Ghost/figma-prompts
/plugin install figma-to-native@figma-prompts
```

You can also run `/plugin` and install from the menu. When installed as a plugin, the skill appears as `figma-to-native:figma-to-native`.

### Claude Code, copied into one project

```
mkdir -p .claude/skills .claude/agents
cp -r skills/figma-to-native .claude/skills/
cp agents/figma-to-native.md .claude/agents/
```

### Claude chat (claude.ai or the Claude app)

Upload `dist/figma-to-native.zip` as a custom skill in your Claude settings. Menu names and plan availability vary, so check your account's skills settings.

Chat has no project folder, so attach your current `Theme.swift` and `Theme.kt` to the conversation whenever they exist. The skill returns an updated theme file whenever it adds roles. Save it and attach it next time.

## Use

Open your app project in Claude Code, make sure a Figma tool is connected (`/mcp`), and send a component link:

```
Use the figma-to-native agent on <Figma link>
```

Optional extras: `ios only`, `android only`, or an output folder. In chat, mention the skill by name if it does not trigger on its own.

Commit the generated theme files. Every later run reads them first. If they are missing, the skill stops and asks for them instead of inventing new ones.

## How the theme stays consistent

- The theme files are the memory. Every run reads them first.
- New roles are inserted with an edit, never a rewrite. Existing roles are never removed or renamed.
- Role names come from the Figma token path in camelCase and are identical on both platforms.
- Colours bound to a component token become a role that aliases a semantic role, never a new hex value.
- Values with no variable binding in Figma are flagged in the report instead of being invented.

## Requirements

- Access to the Figma file. Reading variables per mode needs a Figma tool that can run plugin code. Without one, the skill asks for screenshots or specs.
- iOS output targets iOS 15.8.7 and later. Android output targets minSdk 24. Both are set in `SKILL.md`.
- For Android, add your package name to the Android section of `SKILL.md`, for example: `Use package com.yourcompany.designsystem`.

## Repository layout

```
.claude-plugin/
├── plugin.json              Plugin manifest (name: figma-to-native)
└── marketplace.json         Lets this repo act as a plugin marketplace
skills/figma-to-native/
└── SKILL.md                 All the rules. Single source of truth.
agents/figma-to-native.md    Thin agent that loads the skill
scripts/build-chat-skill.sh  Rebuilds the chat upload zip
dist/figma-to-native.zip     Skill package for Claude chat
```

## Changing the rules

1. Edit `skills/figma-to-native/SKILL.md`.
2. Run `scripts/build-chat-skill.sh` to refresh the chat zip.
3. Commit both, and bump `version` in `.claude-plugin/plugin.json` so plugin users receive the update.

Keep the agent file thin. Do not copy rules into it.

## Known limits

- Don't run two instances at once on different components. Both would edit the same theme files.
- A compile check runs only when `swiftc` or `gradle` and a project are available. Otherwise the skill relies on its own review.
- Output quality depends on how well the Figma file uses variables for colour, spacing and type.
