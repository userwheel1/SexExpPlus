# Sex Grants Experience Plus

Sex Grants Experience Plus awards XP through the Experience mod when a supported scene involving the player ends. This repository contains the mod package and Papyrus source scripts.

## Features

- Awards XP using Experience's progression system.
- Supports SexLab Framework, including SexLab P+, and OStim Standalone.
- Calculates scene rewards from animation or action tags, using the highest matching value.
- Supports configurable creature and multiple-actor bonuses.
- Optional XP loss when the player is counted as a victim.
- Optional orgasm requirement and cooldown.
- Includes an MCM Helper menu and file-based configuration.

## Requirements

- [Experience](https://www.nexusmods.com/skyrimspecialedition/mods/17751)
- JContainers
- PapyrusUtil
- SexLab Framework (classic or P+) and/or OStim Standalone
- MCM Helper (optional; required only for the in-game menu)

## Configuration

- `SKSE/Plugins/SexExpPlus/config.json` contains tag-to-XP values.
- `SKSE/Plugins/SexExpPlus/settings.json` contains default settings when MCM Helper is not installed.
- `SKSE/Plugins/SexExpPlus/config_custom.example.json` shows how to override tag values.

When MCM Helper is installed, its saved settings take precedence over `settings.json`. Users can place personal tag overrides in `config_custom.json`.

## Testing

Tested with the Merethic modlist and SexLab Framework P+ 2.17.0 NG. The Steam installation required by Merethic was Skyrim 1.7.99; the runtime used for the test was Skyrim 1.6.1170.0 with SKSE 2.2.6.

## Credits

SexExpPlus is an independent, from-scratch implementation based on the gameplay mechanics of [Sex Grants Experience](https://www.nexusmods.com/skyrimspecialedition/mods/132720). No original files or code are included or required. I was unable to reach the original author.

## License

The original SexExpPlus work in this repository is released under the [0BSD license](LICENSE). You may use, modify, publish, and redistribute it without asking permission or providing attribution. This license does not grant rights to Skyrim or to third-party files and trademarks.
