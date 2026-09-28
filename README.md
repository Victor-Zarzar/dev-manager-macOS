# macOS Development Environment Manager

A modular, idempotent automated **setup + maintenance** toolkit for macOS, following the same architecture as [dev-manager-rpm](https://github.com/Victor-Zarzar/dev-manager-rpm-desktop) and [dev-manager-arch](https://github.com/Victor-Zarzar/dev-manager-arch): two independent entry points sharing the same `lib/`.

- **`setup.sh`** — installs and configures a complete development environment (based on [dev-setup-macOS](https://github.com/Victor-Zarzar/dev-setup-macOS)): Homebrew, shell tools, databases, GUI apps, dev tools, Python/Flutter tooling, Git and Xcode configuration.
- **`maintenance.sh`** — cleans caches, updates Homebrew, and frees up disk space (based on [dev-cleaner-macOS](https://github.com/Victor-Zarzar/dev-cleaner-macOS)): Xcode/iOS Simulator/IPSW cleanup, Android Studio, the whole Node.js ecosystem, Flutter/FVM, Expo/React Native, dev toolchains (Homebrew/CocoaPods/Ruby/Python), Docker, CrossOver, browsers, IDEs, app caches, system assets, and storage optimization.

## Features

- **Modular Architecture**: Every concern (install or clean) lives in its own library file under `lib/`, shared by both entry points
- **Idempotent Execution**: Safe to run multiple times without duplicating installations or re-cleaning what's already clean
- **Homebrew-first**: formulae and casks for nearly everything, with idempotency checks (`brew list`) before installing
- **Interactive Menus**: Choose individual components or run the complete setup/maintenance routine
- **Automatic Logging**: Detailed timestamped logs for troubleshooting, with failed-command output also printed to the terminal
- **Freed-space reporting**: Cleaning operations report roughly how much disk space each step freed
- **Safety first (maintenance.sh)**: destructive or irreversible cleanups (Xcode Archives, CocoaPods spec repos, Docker volumes, Turbo caches, orphaned `node_modules`, IPSW firmware files) always ask for confirmation before deleting anything

## Requirements

- macOS (any recent version)
- Terminal access
- Internet connection
- Sudo privileges for some operations (Xcode license, DNS flush, Time Machine snapshot thinning, restart)

## Installation

```bash
git clone https://github.com/Victor-Zarzar/dev-manager-macos
cd dev-manager-macos
chmod +x setup.sh maintenance.sh

./setup.sh        # install the dev environment
./maintenance.sh  # clean caches and free up space (run any time after)
```

Both scripts are independent — run either one on its own, whenever you need it.

## Directory Structure

```
dev-manager-macos/
├── setup.sh               # Setup entry point
├── maintenance.sh         # Maintenance/cleaner entry point
├── lib/
│   ├── colors.sh            # Color functions (shared)
│   ├── helpers.sh           # Print/log helpers, header banner, run_command wrapper,
│   │                        # clean_dir_contents/clean_path/format_size, confirm (shared)
│   ├── system.sh            # OS detection (darwin), update_system (brew update/upgrade) (shared)
│   │
│   │   # --- setup.sh modules ---
│   ├── prerequisites.sh     # Xcode Command Line Tools + license checks
│   ├── homebrew.sh          # Homebrew bootstrap + brew_install/brew_cask_install helpers
│   ├── directories.sh       # Project directory scaffolding
│   ├── fonts.sh             # Nerd Font installation
│   ├── shell-tools.sh       # Starship, iTerm2, zsh-autosuggestions, eza, zoxide, bat
│   ├── databases.sh         # SQLite, MySQL, Redis, PostgreSQL, Supabase, Firebase CLI
│   ├── apps.sh              # GUI applications (casks)
│   ├── dev-tools.sh         # Git, NVM, PNPM, Bun, CocoaPods, Nginx, OpenJDK 21, kubectl, Minikube, k9s, mas, Mackup
│   ├── python-tools.sh      # Pyenv, Virtualenv
│   ├── flutter-tools.sh     # FVM, Android Studio
│   ├── git-config.sh        # Git configuration
│   └── xcode-config.sh      # Xcode license/first-launch configuration
│   │
│   │   # --- maintenance.sh modules ---
│   ├── system-update.sh     # Software Update cache cleaning (update_system is in system.sh)
│   ├── ios-clean.sh         # iOS Simulator and IPSW firmware cleaning
│   ├── android-clean.sh     # Android Studio, Emulator & Gradle cleaning
│   ├── node-clean.sh        # NPM/NVM, Bun, PNPM, Yarn, Volta, Turbo, orphan node_modules
│   ├── flutter-clean.sh     # Flutter/Dart/FVM cache cleaning
│   ├── system-clean.sh      # User caches, logs, Xcode DerivedData/Archives, app containers, DNS
│   ├── docker-clean.sh      # Docker/OrbStack system prune
│   ├── storage-optimize.sh  # Old downloads, Trash, Time Machine snapshots, Photos cache
│   ├── restart-macos.sh     # Confirmed restart with countdown
│   ├── crossover-clean.sh   # CrossOver cache (bottles reported, not auto-deleted)
│   ├── expo-clean.sh        # Expo/React Native/Metro/Watchman caches
│   ├── devtools-clean.sh    # Homebrew, CocoaPods, Ruby, Python toolchain cleaning
│   ├── assets-clean.sh      # AssetsV2/iWork templates, iCloud cache, Spotlight rebuild
│   ├── browser-clean.sh     # Chrome, Safari, Orion, Firefox, Brave, Arc, Edge caches
│   ├── ide-clean.sh         # JetBrains IDEs, VS Code, Zed Editor caches
│   └── apps-clean.sh        # Slack, Discord, Spotify caches
└── README.md
```

## Setup Menu Options

```
1)  Run complete setup
2)  Check prerequisites (Xcode License, Command Line)
3)  Install Homebrew only
4)  Setup directories
5)  Install fonts (Nerd Fonts)
6)  Install shell tools (Starship, iTerm2, Eza, Zoxide...)
7)  Install databases (SQLite, Redis, MySQL, PostgreSQL, Supabase, Firebase)
8)  Install applications (LocalSend, Orion, Zed, Notion...)
9)  Install development tools (Git, NVM, Nmap, Mackup, mas, OpenJDK 21...)
10) Install Python tools (Pyenv, Virtualenv)
11) Install Flutter tools (FVM)
12) Configure Git
13) Configure Xcode
14) View installation log
 0) Exit
```

A full setup aborts early if `check_prerequisites` fails (missing Xcode Command Line Tools) so it doesn't try to install everything against a half-configured toolchain — install the CLT (the script triggers the installer for you) and re-run.

## Maintenance Menu Options

```
1)  Run complete maintenance
2)  Update system and Homebrew
3)  Clean update cache
4)  Clean system (caches, logs, Xcode, DNS)
5)  Clean system assets (AssetsV2, iCloud, Spotlight)
6)  Optimize storage
7)  Clean iOS simulator
8)  Clean iOS firmwares (IPSW)
9)  Clean Android Studio & Emulator
10) Clean Node.js (NPM, PNPM, Bun, Yarn, Volta, Turbo)
11) Clean Flutter / Dart / FVM
12) Clean Expo & React Native
13) Clean dev tools (Homebrew, CocoaPods, Ruby, Python)
14) Clean Docker
15) Clean CrossOver cache
16) Clean browser caches
17) Clean IDE caches (JetBrains, VSCode, Zed Editor)
18) Clean app caches (Slack, Discord, Spotify...)
19) View action log
20) Restart macOS
 0) Exit
```

## What Gets Cleaned

### System
- **User caches**: `~/Library/Caches` swept entirely (this is where most apps, including browsers/IDEs, keep their cache — the dedicated browser/IDE/app modules mostly target `Application Support` caches that live outside this folder)
- **Logs & diagnostics**: `~/Library/Logs`, `/Library/Logs/DiagnosticReports`
- **Xcode**: DerivedData, iOS DeviceSupport symbol files (auto re-downloaded per iOS version), Archives (asks for confirmation - these are needed to re-submit past App Store builds)
- **App sandbox containers**: `~/Library/Containers/*/Data/Library/{Caches,Logs}` only - never touches a container's actual app data
- **DNS**: `dscacheutil -flushcache` + `mDNSResponder` restart
- **System assets**: `/Library/Assets/com_apple_MobileAsset_*` (iWork templates etc.), iCloud CloudKit cache, optional Spotlight index rebuild (asks for confirmation - search is briefly unavailable while it rebuilds)

### Development Tools
- **Xcode & iOS Simulator**: DerivedData, unavailable simulator devices (`simctl delete unavailable`), CoreSimulator cache
- **iOS Firmware (IPSW)**: scans known Finder/iTunes cache locations, asks for confirmation before deleting (each file is 3-11 GB)
- **Android Studio & Emulator**: AVD caches, build cache, IDE caches/logs, Gradle cache and wrapper distributions
- **Homebrew**: `brew cleanup --prune=all` + `brew autoremove`
- **CocoaPods**: download cache always, spec repos only with confirmation (they re-clone on next `pod install`)
- **Ruby**: lists rbenv/RVM versions for manual review, `gem cleanup`, gem download cache
- **Python**: lists pyenv versions for manual review, `pip cache purge`, sweeps `__pycache__` under `~/Projects`

### Mobile Development
- **Flutter/Dart/FVM**: Dart pub cache, DevTools cache; reports FVM's cached SDK sizes (not deleted automatically)
- **Expo/React Native**: Expo CLI cache, EAS CLI cache, Watchman watches, Metro bundler cache, React Native Android build artifacts (with confirmation)

### Node.js Ecosystem
- **NPM/NVM**: npm cache, NVM download cache
- **Bun**: install cache, global cache, logs older than 7 days
- **PNPM**: `pnpm store prune`
- **Yarn**: Classic (`yarn cache clean`) and Berry's global cache
- **Volta**: temporary downloads and cache
- **Turbo**: global `~/.turbo` and per-project `.turbo` caches (both ask for confirmation)
- **Orphaned `node_modules`**: scans `~/Projects` for `node_modules` untouched for 30+ days, lists total size, asks for confirmation before deleting

### Browsers, IDEs & Apps
- **Browsers**: Chrome, Safari (cache only), Orion, Firefox, Brave, Arc, Edge
- **IDEs**: JetBrains IDEs (IntelliJ, WebStorm, PyCharm, GoLand, CLion, DataGrip, RubyMine, Rider), VS Code, Zed Editor
- **Apps**: Slack, Discord, Spotify (everything else is already covered by the generic `~/Library/Caches` sweep)

### Other
- **Storage**: downloads older than 30 days, Trash, Time Machine local snapshots (thinned via `tmutil`), Photos app cache
- **Docker/OrbStack**: unused containers, images, networks, build cache; volumes only with confirmation
- **CrossOver**: its own cache/logs cleaned automatically; Wine bottles are only reported (they hold installed Windows apps' data) and left for you to remove manually

## System Restart

`restart_macos` (menu option 20, or automatically suggested after a full maintenance run) asks for confirmation, then gives a 5-second countdown (Ctrl+C to cancel) before `sudo shutdown -r now`.

## Log Files

Each entry point keeps its own timestamped log:

- `setup.sh` → `~/dev_setup_macOS_YYYYMMDD_HHMMSS.log`
- `maintenance.sh` → `~/dev_cleaner_macOS_YYYYMMDD_HHMMSS.log`

If a step fails, the script also prints the last lines of the actual error directly in the terminal (in addition to the log file), so you don't need to open the log to see what went wrong.

## Troubleshooting

**Xcode Command Line Tools installer doesn't appear:**

```bash
xcode-select --install
```

**Homebrew commands not found after install:**

```bash
# Apple Silicon
eval "$(/opt/homebrew/bin/brew shellenv)"
# Intel
eval "$(/usr/local/bin/brew shellenv)"
```

**Permission errors:** several operations (Xcode license, DNS flush, Time Machine, restart) require an administrator password - this is expected.

**Re-running a specific step:**

```bash
./setup.sh        # choose the corresponding menu option
./maintenance.sh  # same idea, for cleaning
```

## License

MIT License

## Author

Victor Zarzar
