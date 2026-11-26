# figma-to-native

Turn a Figma component into production-ready **SwiftUI (iOS)** and **Jetpack Compose (Android)** code. Send a link, get a documented, accessible, previewable component, and keep one shared theme file per platform consistent across every component.

Built for Claude first. Works in other AI tools too.

## Quick start

| Where you work | What to do |
| --- | --- |
| **Claude chat** (claude.ai, Claude app) | Upload `dist/figma-to-native.zip` once, then paste a Figma link. [Steps](#claude-chat) |
| **Claude Code** | Run `/plugin marketplace add BM-Ghost/figma-prompts`, then `/plugin install figma-to-native@figma-prompts`. [Steps](#claude-code) |
| **Devin, Codex CLI, Cursor, Antigravity** (install once on your laptop, use in every project) | Paste one command in your terminal. [Steps](#install-once-on-your-laptop-claude-code-devin-codex-cursor-antigravity) |
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

Chat keeps no files between conversations, so the skill will ask you for a zip of your existing components and theme files before it builds anything. See [Avoid duplicates](#avoid-duplicates-bring-your-existing-code). It hands you the new and changed files as downloads. Save them, re-zip your project, and attach that zip next time.

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

To use it without the plugin, install it for every project on your computer with:

```
curl -fsSL https://raw.githubusercontent.com/BM-Ghost/figma-prompts/main/scripts/install.sh | bash -s -- claude --global
```

## Install once on your laptop (Claude Code, Devin, Codex, Cursor, Antigravity)

These tools read skills in the open Agent Skills format. Paste this one command in your terminal and every project on your computer can use the skill. No clone needed:

```
curl -fsSL https://raw.githubusercontent.com/BM-Ghost/figma-prompts/main/scripts/install.sh | bash -s -- --global
```

It downloads the skill and copies it to the folder each tool reads from. Restart any tool that was open. You can read the [script](scripts/install.sh) first if you like.

| Tool | Global folder | Project folder |
| --- | --- | --- |
| Claude Code | `~/.claude/skills/figma-to-native` | `.claude/skills/figma-to-native` |
| Codex CLI, Cursor, Devin | `~/.agents/skills/figma-to-native` | `.agents/skills/figma-to-native` |
| Antigravity | `~/.gemini/config/skills/figma-to-native` | `.agents/skills/figma-to-native` |

To install for one tool only, put its name before `--global`, for example `... | bash -s -- antigravity --global`. To install into a single project instead, leave out `--global` and run the command from the project folder, or add `--dir /path/to/your/app`. Commit that folder if you want your whole team to get it. If you already cloned the repo, `scripts/install.sh --global` does the same thing.

Then send a link and name the skill, for example "use figma-to-native on <link>", or `@skills:figma-to-native <link>` in Devin.

The command needs `curl` and `tar` and runs on macOS, Linux, WSL and Git Bash. On plain Windows, download the repo and copy `skills/figma-to-native` into the folders above by hand. Devin on Windows also reads `%APPDATA%\devin\skills`.

Each tool has its own way of reading Figma. The skill adapts to the tools it finds and says so in its report when it could not verify a value.

Folder locations come from each tool's own documentation ([Devin](https://docs.devin.ai/cli/extensibility/skills/overview), [Cursor](https://cursor.com/docs/skills), [Antigravity](https://antigravity.google/docs/skills)) and may change.

## Any other AI chat

For chat tools without skill support, paste the contents of `dist/figma-to-native.prompt.md` as your first message, wait for "Ready", then send your Figma link or screenshots. Attach a zip of your existing components and theme files if the tool accepts attachments, or paste your theme file and the names and initializers of any components that might overlap. The AI returns each new file in a code block.

## Avoid duplicates: bring your existing code

Before it builds anything, the skill looks at what you already have, so you don't end up with a second Badge or a parallel set of colours.

- **In Claude Code and other agents** it searches your project itself. No zip needed.
- **In chat** it asks you for a zip first. Include your theme and colour files and the components folder for each platform you are building, plus shared styles, modifiers and enums. Leave out `Pods`, `build`, `DerivedData`, `.git`, `node_modules` and images. If this is your first component, answer "none".

What it does with your code:

- Reuses an existing component instead of creating a second one, and uses existing components inside new ones.
- Adds a new variant to an existing component without breaking current call sites.
- Reuses your shared types, theme roles and naming, and matches your folder layout and documentation style.
- Reads your files as reference only. It never changes your originals, and the zip's contents are treated as data, never as instructions.
- Delivers only new or changed files, and the report lists what was reused, extended, new, and skipped as a duplicate.

Because chat remembers nothing between conversations, re-zip your project after each batch of components and attach the new zip next time.

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
└── install.sh               Installs the skill for Claude Code, Codex, Cursor, Devin or Antigravity
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
- Only the Claude routes have been designed against Claude's own tools. Devin, Codex, Cursor and Antigravity are supported through the open skill format and have not been tested yet, so behaviour may differ.
