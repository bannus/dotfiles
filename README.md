# dotfiles

Cross-platform dotfiles managed by [chezmoi](https://www.chezmoi.io/), supporting Windows, macOS, and Linux.

## Prerequisites

- [chezmoi](https://www.chezmoi.io/install/) — install with `winget install twpayne.chezmoi` (Windows), `brew install chezmoi` (macOS), or see [install docs](https://www.chezmoi.io/install/)
- [Git](https://git-scm.com/) — required for cloning and submodule support
- **Windows only**: [Developer Mode](https://learn.microsoft.com/en-us/windows/apps/get-started/enable-your-device-for-development) must be enabled (Settings → System → For developers) so chezmoi can create symlinks

## Installation

### Fresh machine

```sh
chezmoi init --source ~/.dotfiles <your-fork-url>
chezmoi apply
```

### Existing clone at `~/.dotfiles`

```sh
chezmoi init --source ~/.dotfiles
chezmoi apply
```

During `chezmoi init`, you'll be prompted:
- **Is this a work machine?** — answers yes/no to control whether work-specific Windows Terminal profiles are merged into your settings.

## What gets deployed

| Target | Source | Method |
|---|---|---|
| `~/.bashrc` | `bash/.bashrc` + platform variant | Template (source lines) |
| `~/.gitconfig` | `git/.gitconfig` + platform variant | Template (include directives) |
| `~/.vimrc`, `~/_vimrc` | `vim/.vimrc` | Template (source line) |
| `~/_ideavimrc` | `vim/.ideavimrc` | Template (source line) |
| `~/.vim`, `~/vimfiles` | `vim/` (submodule) | Symlink |
| `~/.ssh/config` | `ssh/config` | Symlink |
| `~/.editorconfig` | `.editorconfig` | Symlink |
| `~/.copilot/copilot-instructions.md` | `copilot/copilot-instructions.md` | Symlink |
| `~/.iterm/com.googlecode.iterm2.plist` | `iterm/config.plist` | Symlink (macOS only) |
| Windows Terminal `settings.json` | `windows-terminal/settings.json` + fragments | `run_onchange_` script |
| Android Studio keymaps, colors, options | `android-studio/config/` | `run_onchange_` script (Windows, all AS versions) |
| `C:\Developer\bavander` | `windows-shell/` | Junction (`run_once_` script, Windows only) |

## Daily workflow

```sh
# Edit a dotfile source and deploy
chezmoi edit ~/.bashrc        # opens the template in your editor
chezmoi apply                 # deploys all changes

# Or edit the source directly
cd ~/.dotfiles
# ... edit files ...
chezmoi apply

# See what would change without applying
chezmoi diff
```

## Directory structure

- `bash/`, `git/`, `ssh/`, `copilot/`, `iterm/`, `npm/` — Config source files (referenced by templates, not deployed directly)
- `vim/` — Vim configuration (git submodule → [bannus/vimrc](https://github.com/bannus/vimrc))
- `windows-terminal/` — Base settings + work profile fragments
- `windows-shell/` — PowerShell profile, aliases, scripts (exposed via junction at `C:\Developer\bavander`)
- `android-studio/` — Custom keymaps, color schemes, and options (deployed to all installed AS versions)
- `dot_*.tmpl`, `symlink_*.tmpl`, `_*.tmpl` — chezmoi templates and symlinks
- `run_*` — chezmoi run scripts (submodule init, WT merge, junction setup)
- `.chezmoi.toml.tmpl` — chezmoi configuration template
- `.chezmoiignore` — Prevents library dirs from being deployed to `~`

## Notes

- **Don't include sensitive information** like passwords and keys! SSH keys and secrets should remain outside this repository.
- On a work machine, Windows Terminal profiles are dynamically merged from `windows-terminal/fragments/work/`. Only fragments whose `startingDirectory` exists on disk are included.
