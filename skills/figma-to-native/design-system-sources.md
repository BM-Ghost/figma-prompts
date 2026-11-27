# Design system sources

These are the Figma files the figma-to-native skill reads on every run. Edit this file when a link changes. A link the user gives in a message overrides it, and so does a `design-system-sources.md` found in the user's own project.

Use the file key to open a file. The start node is only a hint for where to begin looking. The Figma API writes node ids with a colon, links write them with a hyphen.

| Purpose | Figma file | File key | Start node | Link |
| --- | --- | --- | --- | --- |
| Colours, dimensions and typography (variables) | IGN: Styleguide | `wiFwC7ysU5mPi8aYLaUjjQ` | `8:116` | https://www.figma.com/design/wiFwC7ysU5mPi8aYLaUjjQ/IGN--Styleguide?node-id=8-116 |
| Icons | IGN: Icon Library | `k7OPiYceVZZXFFRo7UCkQt` | `0:1` | https://www.figma.com/design/k7OPiYceVZZXFFRo7UCkQt/IGN--Icon-Library?node-id=0-1 |
| Components (the files users link to) | IGN: Component Library | `2JuIsIlITssuShylFeHM8q` | none | https://www.figma.com/design/2JuIsIlITssuShylFeHM8q |

## Variable collections in the Styleguide

- **Color - Semantics**: the semantic colours. Modes: **Light**, **Dark** and **Ignite**. All three are supported. Use the semantic colours, never the primitives.
- **Component**: component tokens that alias semantic tokens, for example `field/label` points to `text/tertiary`.
- **Color - Primitives**: the raw palette. Never used directly in code.
- **Dimensions**: spacing, sizing and radii.
- **Typography**: font families, sizes, weights and line heights.

## Mode mapping

- **Light** and **Dark** follow the system appearance.
- **Ignite** is selected explicitly by the host app and overrides the system appearance.
