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

## Build and packaging

This repository already includes the compiled `Scripts/*.pex` files and the plugin `SexExpPlus.esp`. To install this exact version, you do not need to compile anything. Clone the repository or download and extract its ZIP, then install the package files with your mod manager.

To create a mod-manager ZIP from the repository root in PowerShell, run:

```powershell
Compress-Archive -Path MCM, Scripts, SKSE, SexExpPlus.esp -DestinationPath SexExpPlus.zip -Force
```

The archive should have `MCM`, `Scripts`, `SKSE`, and `SexExpPlus.esp` at its root. If you download GitHub's automatically generated source ZIP, extract it first and create the mod ZIP from inside the extracted repository folder. Do not put the extra repository folder level inside the mod ZIP.

### Recompiling Papyrus scripts

The `.psc` files in `Source/Scripts` are Papyrus source. Compiling them produces `.pex` files; it does not create or update `SexExpPlus.esp`. The ESP is a Creation Kit plugin containing the quest and alias records that host the scripts. If you only change Papyrus code while keeping the same script names and plugin records, recompile the scripts and replace the corresponding `.pex` files. Changes to plugin records or script attachments must be made and saved in the Creation Kit (or another plugin editor).

Install the Skyrim Creation Kit compiler and make sure the compiler can find the source headers for Skyrim, SKSE, JContainers, PapyrusUtil, SexLab, OStim, and MCM Helper. The exact import directories depend on where those headers are installed. From the repository root, adapt and run this PowerShell example:

```powershell
$Skyrim = 'E:\Path\To\Skyrim Special Edition'
$Repo = (Get-Location).Path
$Compiler = Join-Path $Skyrim 'Papyrus Compiler\PapyrusCompiler.exe'
$Flags = Join-Path $Skyrim 'Papyrus Compiler\TESV_Papyrus_Flags.flg'
$Output = Join-Path $Repo 'Build\Scripts'

New-Item -ItemType Directory -Force -Path $Output | Out-Null
$ImportDirs = @(
    (Join-Path $Repo 'Source\Scripts'),
    (Join-Path $Skyrim 'Data\Scripts\Source'),
    'C:\Path\To\Other\Mod\Source\Scripts'
)
$Imports = $ImportDirs -join ';'

& $Compiler (Join-Path $Repo 'Source\Scripts') -all "-i=$Imports" "-o=$Output" "-f=$Flags"
if ($LASTEXITCODE -ne 0) { throw 'Papyrus compilation failed.' }
Copy-Item (Join-Path $Output '*.pex') (Join-Path $Repo 'Scripts') -Force
```

Replace the example paths and add an import directory for each dependency whose `.psc` headers are not already in one of the listed folders. The compiler's `-all` option compiles the source scripts in the specified folder. After compilation, create or update the mod ZIP using the command above.

For a Papyrus compiler option reference, see the [Skyrim Papyrus Compiler Reference](https://open-papyrus.github.io/docs/Creation_Kit/Skyrim/Compiler_Reference.html).

## Testing

Tested with the [Merethic modlist](https://github.com/iAmMe27/Merethic) and [SexLab Framework P+ 2.17.0 NG](https://www.loverslab.com/files/file/25318-sexlab-p/). The Steam installation required by Merethic usually latest and it was Skyrim 1.7.99; the runtime used for the test was Skyrim 1.6.1170.0 with SKSE 2.2.6.

## Credits

SexExpPlus is an independent, from-scratch implementation based on the gameplay mechanics of [Sex Grants Experience](https://www.nexusmods.com/skyrimspecialedition/mods/132720). No original files or code are included or required. I was unable to reach the original author.

## License

The original SexExpPlus work in this repository is released under the [0BSD license](LICENSE). You may use, modify, publish, and redistribute it without asking permission or providing attribution. This license does not grant rights to Skyrim or to third-party files and trademarks.
