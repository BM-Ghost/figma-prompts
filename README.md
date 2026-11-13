# figma-to-native

Turn a Figma component into production-ready **SwiftUI (iOS)** and **Jetpack Compose (Android)** code. Send a link, get a documented, accessible, previewable component, and keep one shared theme file per platform consistent across every component.

Built for Claude first. Works in other AI tools too.

## Quick start

| Where you work | What to do |
| --- | --- |
| **Claude chat** (claude.ai, Claude app) | Upload `dist/figma-to-native.zip` once, then paste a Figma link. [Steps](#claude-chat) |
| **Claude Code** | Run two `/plugin` commands once, then send a link. [Steps](#claude-code) |
| **Devin, Codex CLI, Cursor and other agents** | Run `scripts/install.sh agents`, then send a link. [Steps](#other-ai-agents) |
| **Any other AI chat** | Paste `dist/figma-to-native.prompt.md`, then send a link. [Steps](#any-other-ai-chat) |

## What you get

For each component and platform:

- one component file named after its primary type, with variants, states, previews, Dark mode, RTL and large-text support
- a shared theme file (`Theme.swift`, `Theme.kt`), created with the first component and extended afterwards, so colours, spacing and type never drift between components
- a short report with a usage example, assumptions, and anything in the design that is not tied to a design-system variable

## Claude chat

1. In Settings, turn on **Code execution and file creation** (called "Create and edit files" in newer layouts).
2. Go to **Customize, then Skills**, click **+**, choose **Create skill**, then **Upload a skill**, and upload `dist/figma-to-native.zip`. Switch it on.
3. Start a chat, paste a Figma component link and say "use figma-to-native on this".

Chat keeps no files between conversations. The skill hands you `Theme.swift` and `Theme.kt` as downloads. Save them and attach the latest ones at the start of your next conversation.

Reading your design needs a Figma connector in chat. Without one, the skill asks for screenshots or specs.

## Claude Code

```
/plugin marketplace add BM-Ghost/figma-prompts
/plugin install figma-to-native@figma-prompts
```

You can also run `/plugin` and install from the menu. Then open your app project and send:

```
Use the figma-to-native agent on <Figma link>
```

Optional extras: `ios only`, `android only`, or an output folder. Commit the generated theme files. Every later run reads them first.

To use it without the plugin, run `scripts/install.sh claude` from your project, or add `--global` to install for every project.

## Other AI agents

Devin, Codex CLI, Cursor and other tools read skills in the open Agent Skills format. Install into your project:

```
scripts/install.sh agents --dir /path/to/your/app
```

This copies the skill to `.agents/skills/figma-to-native`, a folder Devin and Codex both read. Use `--global` to install into your home folder instead. Then send a link and name the skill, for example "use figma-to-native on <link>", or `@skills:figma-to-native <link>` in Devin.

Each tool has its own way of reading Figma. The skill adapts to the tools it finds and says so in its report when it could not verify a value.

## Any other AI chat

For chat tools without skill support, paste the contents of `dist/figma-to-native.prompt.md` as your first message, wait for "Ready", then send your Figma link or screenshots. Paste your current `Theme.swift` and `Theme.kt` if you have them. The AI returns each file in a code block.

## How the theme stays consistent

- The theme files are the memory. Every run reads them first.
- New roles are inserted with an edit, never a rewrite. Existing roles are never removed or renamed.
- Role names come from the Figma token path in camelCase and are identical on both platforms.
- Colours bound to a component token become a role that aliases a semantic role, never a new hex value.
- Values with no variable binding in Figma are flagged in the report instead of being invented.

## Requirements

- Access to the Figma file, through a connector or tool that can read variables per mode. Without one, the skill asks for screenshots or specs.
- iOS output targets iOS 15.8.7 and later. Android output targets minSdk 24. Both are set in `SKILL.md`.
- For Android, add your package name to the Android section of `SKILL.md`, for example: `Use package com.yourcompany.designsystem`.

## Repository layout

```
.claude-plugin/
├── plugin.json              Claude Code plugin manifest (name: figma-to-native)
└── marketplace.json         Lets this repo act as a plugin marketplace
skills/figma-to-native/
└── SKILL.md                 All the rules. Single source of truth.
agents/figma-to-native.md    Claude Code agent that loads the skill
scripts/
├── build.sh                 Builds the chat zip and the paste-ready prompt
└── install.sh               Installs the skill for Claude Code or other agents
dist/
├── figma-to-native.zip          Claude chat upload
└── figma-to-native.prompt.md    Paste-ready prompt for any AI chat
```

## Changing the rules

1. Edit `skills/figma-to-native/SKILL.md`. It is the only place rules live.
2. Run `scripts/build.sh` to refresh both files in `dist/`.
3. Commit, and bump `version` in `.claude-plugin/plugin.json` so plugin users receive the update.

Keep the agent file thin. Do not copy rules into it.

## Known limits

- Don't run two instances at once on different components. Both would edit the same theme files.
- A compile check runs only when `swiftc` or `gradle` and a project are available. Otherwise the skill relies on its own review.
- Output quality depends on how well the Figma file uses variables for colour, spacing and type.
- Only the Claude routes have been designed against Claude's own tools. Other agents are supported through the open skill format and may behave differently.
