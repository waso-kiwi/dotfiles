# dotfiles

My Fedora (niri) setup, so a new machine can be rebuilt quickly.

## What's here

- `config/` → symlinked into `~/.config/` (niri, DankMaterialShell, nvim/LazyVim, ghostty)
- `home/` → symlinked into `~` (`.bashrc`, `.bash_profile`, `.gitconfig`)
- `bin/` → symlinked into `~/.local/bin/` (personal scripts)
- `packages/` → lists of installed dnf packages, copr repos, and flatpaks

## Setting up a new machine

1. Install Fedora, clone this repo:
   ```
   git clone https://github.com/<you>/dotfiles.git ~/dotfiles
   ```
2. Run the bootstrap script:
   ```
   ~/dotfiles/bootstrap.sh
   ```
   It symlinks everything into place and offers to install the packages/copr repos/flatpaks
   from `packages/`. Any real file already sitting where a symlink needs to go gets renamed
   to `<file>.bak-<timestamp>` first, nothing is deleted.
3. Log out and back in (or reboot) so niri/the shell picks everything up.

## Keeping it up to date

- Edit the files normally at their usual `~/.config/...` paths — they're symlinks into this
  repo, so changes show up here automatically. Just `git add`/`commit`/`push` when you want
  to save progress.
- Before committing, refresh the package lists:
  ```
  ~/dotfiles/dump-packages.sh
  ```
