#! /bin/bash
set -x

# Symlink the aliases from wherever this repo is cloned.
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
rm -f "$HOME/.custom_aliases"
ln -s "$DOTFILES_DIR/.custom_aliases" "$HOME/.custom_aliases"

# If a previous run left ~/.zshrc as a dangling symlink, clear it so the
# machine's own zsh/oh-my-zsh config can be written normally.
if [ -L "$HOME/.zshrc" ] && [ ! -e "$HOME/.zshrc" ]; then
  rm -f "$HOME/.zshrc"
fi

# Source the aliases from the machine's existing shell config (idempotent —
# only appends once per file, and never replaces the file). Both are covered
# because default shells differ across environments (zsh on EFS boxes,
# bash on Codespaces).
for rc in .zshrc .bashrc; do
  if ! grep -qs "custom_aliases" "$HOME/$rc"; then
    printf '\n# Load custom aliases (added by dotfiles/install.sh)\n[ -f "$HOME/.custom_aliases" ] && source "$HOME/.custom_aliases"\n' >> "$HOME/$rc"
  fi
done

# Persist tool state from the EFS drive when the platform provides it.
# Shell config (.zshrc, .zshenv, .zprofile, .oh-my-zsh) is intentionally
# NOT managed here — the machine image already sets that up.
if [ -n "$EFS_MOUNT_POINT" ] && [ -d "$EFS_MOUNT_POINT" ]; then
  for segment in .claude .claude.json .codex .zsh_history .cursor .cursor-server; do
    # Never delete a home file in favor of a symlink that would dangle.
    if [ ! -e "$EFS_MOUNT_POINT/$segment" ]; then
      continue
    fi
    rm -rf "$HOME/$segment"
    ln -s "$EFS_MOUNT_POINT/$segment" "$HOME/$segment" || true
  done
fi
