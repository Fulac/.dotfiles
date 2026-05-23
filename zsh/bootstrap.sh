#!/usr/bin/env bash
#
# Multi-distro dotfiles bootstrap script
#
# Supported distros:
#   - Arch family   (cachyos, arch, manjaro, endeavouros)  -> paru/pacman
#   - Fedora family (fedora, rhel, rocky, almalinux)       -> dnf + official scripts
#   - Debian family (ubuntu, debian, linuxmint)            -> apt + official scripts
#
# Usage:
#   ./bootstrap.sh              # normal run
#   DRY_RUN=1 ./bootstrap.sh    # show what would be executed

set -euo pipefail

# --------------------------------------------
# Utilities
# --------------------------------------------
log()  { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m==>\033[0m %s\n' "$*" >&2; }
err()  { printf '\033[1;31m==>\033[0m %s\n' "$*" >&2; exit 1; }

run() {
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    printf '   [dry-run] %s\n' "$*"
  else
    "$@"
  fi
}

has() { command -v "$1" >/dev/null 2>&1; }

# --------------------------------------------
# Preflight checks
# --------------------------------------------
[[ $EUID -eq 0 ]] && err "Do not run as root. Use a regular user account."
[[ -f /etc/os-release ]] || err "/etc/os-release not found. Unsupported OS."

# Source /etc/os-release to expose ID, ID_LIKE, etc. as variables
# shellcheck disable=SC1091
. /etc/os-release

# Detect distro family
DISTRO_FAMILY=""
case "${ID:-}" in
  arch|cachyos|manjaro|endeavouros|garuda)
    DISTRO_FAMILY="arch" ;;
  fedora|rhel|centos|rocky|almalinux)
    DISTRO_FAMILY="fedora" ;;
  ubuntu|debian|linuxmint|pop)
    DISTRO_FAMILY="debian" ;;
  *)
    # Fallback: check ID_LIKE for derivative distros
    case "${ID_LIKE:-}" in
      *arch*)    DISTRO_FAMILY="arch" ;;
      *fedora*|*rhel*) DISTRO_FAMILY="fedora" ;;
      *debian*)  DISTRO_FAMILY="debian" ;;
      *) err "Unsupported distro: ${ID:-unknown}" ;;
    esac
    ;;
esac

log "Distro: ${PRETTY_NAME:-$ID}  (family: ${DISTRO_FAMILY})"

# --------------------------------------------
# Package manager wrapper
# --------------------------------------------
# install_pkg <pkg1> [pkg2 ...]
#   - Skips packages that are already installed
#   - On Arch family, prefers paru over pacman
install_pkg() {
  local pkgs=("$@")
  local to_install=()

  case "$DISTRO_FAMILY" in
    arch)
      for p in "${pkgs[@]}"; do
        if pacman -Qi "$p" >/dev/null 2>&1; then
          log "$p: already installed (pacman)"
        else
          to_install+=("$p")
        fi
      done
      (( ${#to_install[@]} == 0 )) && return 0

      if has paru; then
        run paru -S --needed --noconfirm "${to_install[@]}"
      else
        run sudo pacman -S --needed --noconfirm "${to_install[@]}"
      fi
      ;;
    fedora)
      for p in "${pkgs[@]}"; do
        if rpm -q "$p" >/dev/null 2>&1; then
          log "$p: already installed (rpm)"
        else
          to_install+=("$p")
        fi
      done
      (( ${#to_install[@]} == 0 )) && return 0
      run sudo dnf install -y "${to_install[@]}"
      ;;
    debian)
      for p in "${pkgs[@]}"; do
        if dpkg -s "$p" >/dev/null 2>&1; then
          log "$p: already installed (dpkg)"
        else
          to_install+=("$p")
        fi
      done
      (( ${#to_install[@]} == 0 )) && return 0
      run sudo apt-get update -qq
      run sudo apt-get install -y "${to_install[@]}"
      ;;
  esac
}

# --------------------------------------------
# Common base packages
# --------------------------------------------
# Available via package manager on every supported distro
log "Installing base packages"
install_pkg zsh git curl

# --------------------------------------------
# Per-family main tooling
# --------------------------------------------
# Install the modern CLI toolset required by .zshrc
# Tools: zsh-plugin manager (sheldon), prompt (starship), Python toolchain (uv),
#        ls/cat/grep/find replacements (eza/bat/ripgrep/fd), smart cd (zoxide)
case "$DISTRO_FAMILY" in
  arch)
    # All tools are available in official repos or AUR
    log "Arch family: installing all tools via package manager"
    install_pkg sheldon starship uv bat ripgrep fd eza zoxide
    ;;

  fedora)
    # Most tools are in official repos; sheldon and uv require official scripts (see below)
    log "Fedora family: dnf + official scripts"
    install_pkg starship bat ripgrep fd-find eza zoxide
    ;;

  debian)
    # Only a subset is reliably packaged on apt; starship/sheldon/uv/eza/zoxide
    # are installed via official scripts below (apt versions are often stale or missing)
    log "Debian family: apt + official scripts"
    install_pkg bat ripgrep fd-find
    ;;
esac

# --------------------------------------------
# Official-script installs (non-Arch only)
# --------------------------------------------
# Tools missing or outdated in Fedora/Debian repos are installed here.
# All binaries go to user-local locations (~/.local/bin, ~/.cargo/bin) so no sudo is required.
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

if [[ "$DISTRO_FAMILY" != "arch" ]]; then
  # --- starship: Debian only (Fedora already covered via dnf) ---
  if ! has starship; then
    log "Installing starship via official script"
    run sh -c 'curl -sS https://starship.rs/install.sh | sh -s -- -y --bin-dir "$HOME/.local/bin"'
  fi

  # --- uv: official script handles both Fedora and Debian ---
  if ! has uv; then
    log "Installing uv via official script"
    run sh -c 'curl -LsSf https://astral.sh/uv/install.sh | sh'
  fi

  # --- sheldon: prefer cargo-binstall for prebuilt binary, fall back to upstream installer ---
  if ! has sheldon; then
    log "Installing sheldon"
    if has cargo-binstall; then
      run cargo binstall -y sheldon
    else
      # Upstream installer fetches the release binary and places it in ~/.local/bin
      run sh -c 'curl --proto "=https" --tlsv1.2 -LsSf https://rossmacarthur.github.io/install/crate.sh \
        | bash -s -- --repo rossmacarthur/sheldon --to "$HOME/.local/bin"'
    fi
  fi

  # --- zoxide: official script (apt has it on newer Ubuntu, but the script is more reliable) ---
  if ! has zoxide; then
    log "Installing zoxide via official script"
    run sh -c 'curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh'
  fi
fi

# --------------------------------------------
# Final verification
# --------------------------------------------
REQUIRED=(zsh git curl sheldon starship uv)
missing=()
for cmd in "${REQUIRED[@]}"; do
  has "$cmd" || missing+=("$cmd")
done

if (( ${#missing[@]} > 0 )); then
  warn "Missing commands required by .zshrc: ${missing[*]}"
  warn "Install them manually."
else
  log "All tools required by .zshrc are present."
fi

log "Bootstrap complete. Start a new shell: exec zsh"
