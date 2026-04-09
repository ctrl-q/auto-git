# auto-git

Automatically stages and commits file changes in a git repository.

- Commits any staged changes left over from a previous run
- Stages modified/deleted tracked files idle for more than 15 minutes
- Stages untracked symlinks and files matching patterns in `$XDG_CONFIG_HOME/auto-git/known-patterns`
- Sends a desktop notification for untracked files with no matching known pattern

## Usage

Set `AUTOGIT_REPO_ROOT` to the target repository path and run `auto-git` (e.g. via a systemd timer).

## Dependencies

`bash`, `coreutils`, `findutils`, `gawk`, `git`, `grep`, `libnotify`, `open-in-terminal`
