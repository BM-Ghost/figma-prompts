# figma-prompts

A Claude Code plugin, skill and agent that turn a Figma component link into drop-in SwiftUI and Jetpack Compose files, while keeping one shared theme file per platform consistent across every component.

## Repository layout

```
.claude-plugin/
├── plugin.json              Plugin manifest (name: figma-components)
└── marketplace.json         Lets this repo act as a plugin marketplace
skills/
└── figma-component-generator/
    └── SKILL.md             All the rules. Single source of truth.
agents/
└── component-generator.md   Thin agent that loads the skill
scripts/
└── build-chat-skill.sh      Rebuilds the chat upload zip
dist/
└── figma-component-generator.zip   Skill package for Claude chat
```

The skill holds every rule. The agent only loads the skill, so the two never drift apart.

## Install

### Claude Code, as a plugin (recommended for the team)

```
/plugin marketplace add BM-Ghost/figma-prompts
/plugin install figma-components@figma-prompts
```

Run `/plugin` to browse and install from a menu if you prefer. Once installed, the skill and agent are available in every project. When installed as a plugin, they appear with the `figma-components:` prefix.

### Claude Code, copied into one project

Copy the two folders into the project's `.claude` directory and commit them:

```
mkdir -p .claude/skills .claude/agents
cp -r skills/figma-component-generator .claude/skills/
cp agents/component-generator.md .claude/agents/
```

### Claude chat (claude.ai or the Claude app)

Upload `dist/figma-component-generator.zip` as a custom skill in your Claude settings (Settings, then Capabilities, then Skills; menu names may differ by plan and app version). Skills may be unavailable on some plans.

In chat there is no project folder, so attach your current `Theme.swift` and `Theme.kt` to the conversation whenever they already exist. The skill returns an updated theme file whenever it adds roles. Save that file and attach it next time.

## Use

Send a Figma component link:

```
Use component-generator on <Figma link>
```

Optional extras in the same message: `ios only`, `android only`, or an output folder. In chat, mention the skill by name ("use figma-component-generator") if it does not trigger on its own.

## What you get

For each component and platform:

- one component file named after its primary type
- the shared theme file, created with the first component and extended afterwards

Default locations in a project that has no theme yet:

```
DesignSystem/iOS/Theme.swift
DesignSystem/Android/Theme.kt
```

## How the theme stays consistent

- The theme files are the memory. Every run reads them first.
- New roles are inserted with an edit, never a rewrite. Existing roles are never removed or renamed.
- Role names come from the Figma token path in camelCase and are identical on both platforms.
- Colours bound to a component token become a role that aliases a semantic role, never a new hex value.
- Values with no variable binding in Figma are flagged in the report instead of being invented.

## Requirements

- Access to the Figma file. Reading variables per mode needs a Figma tool that can run plugin code. Without one, the skill asks for screenshots or specs.
- For Android, add your package name to the Android section of `SKILL.md`, for example: `Use package com.yourcompany.designsystem`.

## Changing the rules

1. Edit `skills/figma-component-generator/SKILL.md`.
2. Run `scripts/build-chat-skill.sh` to refresh the chat zip.
3. Commit both, and bump `version` in `.claude-plugin/plugin.json` so plugin users receive the update.

Keep the agent file thin. Do not copy rules into it.

## Known limits

- Don't run two instances at once on different components. Both would edit the same theme files.
- A compile check runs only when `swiftc` or `gradle` and a project are available. Otherwise the skill relies on its own review.
- The repository is public. Anyone can read these rules.
