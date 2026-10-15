#!/bin/bash
# SessionStart hook: installs Ghidra and the Hopper demo for REA in Claude Code cloud sessions.
# Runs in the background so session startup is not blocked; progress goes to $LOG.
set -u

[ "${CLAUDE_CODE_REMOTE:-}" = "true" ] || exit 0

LOG=/tmp/re-engines-install.log
GHIDRA_TAG=Ghidra_12.1.4_build
GHIDRA_DIR=/opt/ghidra_12.1.4_PUBLIC
HOPPER_URL=https://www.hopperapp.com/downloader/public/Hopper-6.4.2-Linux-demo.deb
# Size and digest published in rea-agents@6.5.0's Hopper install plan.
HOPPER_SHA1=e4f79dff602648a8ff4a88b773875b6bfac0dc65

install_ghidra() {
  if [ -x "$GHIDRA_DIR/support/analyzeHeadless" ]; then echo "ghidra: already installed"; return 0; fi
  local work path
  work=$(mktemp -d)
  path=$(curl -fsSL "https://github.com/NationalSecurityAgency/ghidra/releases/expanded_assets/$GHIDRA_TAG" \
    | grep -oE "/NationalSecurityAgency/ghidra/releases/download/$GHIDRA_TAG/ghidra_12\.1\.4_PUBLIC_[0-9]+\.zip" | head -1)
  if [ -z "$path" ]; then echo "ghidra: cannot reach github.com release page (network policy?)"; rm -rf "$work"; return 1; fi
  curl -fsSL -o "$work/ghidra.zip" "https://github.com$path" || { echo "ghidra: download failed"; rm -rf "$work"; return 1; }
  unzip -q "$work/ghidra.zip" -d /opt || { echo "ghidra: unzip failed"; rm -rf "$work"; return 1; }
  # REA discovers Ghidra through ghidraRun on PATH when GHIDRA_INSTALL_DIR is unset.
  ln -sf "$GHIDRA_DIR/ghidraRun" /usr/local/bin/ghidraRun
  rm -rf "$work"
  echo "ghidra: installed at $GHIDRA_DIR"
}

install_hopper() {
  if [ -x /opt/hopper/bin/Hopper ]; then echo "hopper: already installed"; return 0; fi
  local work
  work=$(mktemp -d)
  curl -fsSL -o "$work/hopper.deb" "$HOPPER_URL" || { echo "hopper: cannot reach www.hopperapp.com (network policy?)"; rm -rf "$work"; return 1; }
  echo "$HOPPER_SHA1  $work/hopper.deb" | sha1sum -c --quiet || { echo "hopper: SHA-1 mismatch, not installing"; rm -rf "$work"; return 1; }
  DEBIAN_FRONTEND=noninteractive apt-get install -y "$work/hopper.deb" xvfb xauth python3 libx11-6 libxtst6 >/dev/null \
    || { echo "hopper: apt-get install failed"; rm -rf "$work"; return 1; }
  rm -rf "$work"
  echo "hopper: installed (demo mode)"
}

(
  echo "== $(date -Is) REA engine install"
  install_ghidra
  install_hopper
  echo "== done"
) >>"$LOG" 2>&1 &
disown
exit 0
