# tomlinks

backup restoration software oriented for package-based dotfiles

## Installation

```bash
odin build .
sudo mv tomlinks /bin/tomlinks
```

## Usage

tomlinks reads `tomlinks.ini` files that contain source-to-destination mappings.

**Format** (in `tomlinks.ini`):
```
source_path = destination_path
```

Destinations can use `~` which will be expanded to your home directory.

### Commands

| Command | Description |
|---|---|
| `tomlinks restore <dir>` | Restores files from backup directory to their destinations. Copies files from the package to config/home locations. |
| `tomlinks collect <dir>` | Collects files from destinations into the backup directory. Reverse of restore — saves current config files into the backup package. |
| `tomlinks restore *` | Restore all backup packages (directories with `tomlinks.ini`) in the current directory |
| `tomlinks collect *` | Collect files from destinations TO backup packages (create backup of configs) |
| `tomlinks help` | Show this help message |

### Examples

**Example `tomlinks.ini`:**
```
config.fish = ~/.config/fish/config.fish
gitconfig = ~/.gitconfig
```

**Restore example:**
```bash
# From the project root with a tomlinks.ini:
tomlinks restore .
# Or with a specific directory:
tomlinks restore ./backup-dir
```

**Collect example:**
```bash
tomlinks collect .
# Collects ~/.config/fish/config.fish and ~/.gitconfig into the backup directory
```

### Use cases

#### Separate user and root directories

You can use separate backup directories for regular user and root, allowing `sudo tomlinks restore` to work for root without affecting your user files. This works not just for dotfiles (`~/`), but also for system-wide configs like `/etc/`:

```bash
# User's backup directory (~/.local/tomlinks/ or ./tomlinks/)
tomlinks restore .

# As root with a separate root backup directory (for /etc/ and system configs):
sudo tomlinks restore /path/to/root-backup-dir
```

This is useful when you want to manage system configuration for root separately, or when your root system has different config locations than your user home.

#### Per-project dotfile management

Initialize a tomlinks.ini in any project directory and use restore/collect to manage that project's dotfiles:

```bash
# Restore project dotfiles to home
tomlinks restore /path/to/project

# Collect home configs into project backup
tomlinks collect /path/to/project
```
