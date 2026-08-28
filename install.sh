#! /bin/bash
set -x

# All of these segments will be symlinked from the home directory to your EFS drive.
# You can safely customize this list.
for segment in .claude .claude.json .codex .oh-my-zsh .zshenv .zprofile .zsh_history .zshrc .custom_aliases .cursor .cursor-server; do
  # If you don't want to delete what's currently in the home directory, remove this.
  if [ -e "$HOME/$segment" ]; then
    rm -rf "$HOME/$segment"
  fi
  # Don't fail if the symlink already exists.
  ln -s "$EFS_MOUNT_POINT/$segment" "$HOME" || true
done

# Make zsh the default shell so .zshrc (and .custom_aliases) load in every session.
if [ "$(basename "$SHELL")" != "zsh" ] && command -v zsh >/dev/null 2>&1; then
  sudo chsh "$(id -un)" --shell "$(command -v zsh)"
fi
