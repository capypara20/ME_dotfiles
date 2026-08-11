#!/usr/bin/env bash
# ==================================================================
# Linux 用 dotfiles 収集スクリプト（install.sh の逆方向）
#
# やること:
#   今このPCで使っている設定ファイルを、dotfiles リポジトリへコピーし直す。
#
# 使い方:
#   cd ~/dotfiles
#   bash sync.sh            # 取り込む
#   bash sync.sh --dry-run  # 何が起きるか表示するだけ
#   git diff                # 取り込んだ差分を確認
#   git add -A && git commit -m "設定を更新" && git push
# ==================================================================

set -eu

DOTDIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

DRYRUN=0
if [ "${1:-}" = "--dry-run" ]; then
  DRYRUN=1
  echo "*** DryRun モード: 実際には何も変更しません ***"
fi

info() { echo "  $1"; }
step() { echo ""; echo "[$1]"; }
ok()   { echo "  OK   $1"; }
skip() { echo "  --   $1"; }

# ------------------------------------------------------------------
# PC 側 → リポジトリ へコピー
# フォルダの場合はリポジトリ側を一度消してからコピーする。
# （そうしないと「PCで消したファイル」がリポジトリに残り続けるため）
# 引数: 表示名 コピー元(PC側) コピー先(リポジトリ側)
# ------------------------------------------------------------------
collect() {
  label="$1"; src="$2"; dst="$3"

  if [ ! -e "$src" ]; then
    skip "$label : $src が無いので飛ばします"
    return
  fi

  info "$label : $src"
  info "       -> $dst"

  if [ "$DRYRUN" -eq 0 ]; then
    if [ -d "$src" ]; then
      rm -rf "$dst"
    fi
    mkdir -p "$(dirname "$dst")"
    cp -r "$src" "$dst"
  fi
  ok "$label"
}

# ==================================================================
# nvim
# ==================================================================
step "nvim の設定を取り込み"
collect "nvim" "$CONFIG_HOME/nvim" "$DOTDIR/nvim"

# ==================================================================
# bash
# ==================================================================
step "bash の設定を取り込み"
collect ".bashrc" "$HOME/.bashrc" "$DOTDIR/bash/.bashrc"

# ==================================================================
# PowerShell
# ==================================================================
step "PowerShell プロファイルを取り込み"
collect "PowerShell profile" \
  "$CONFIG_HOME/powershell/profile.ps1" \
  "$DOTDIR/powershell/profile.ps1"

# ==================================================================
# VSCode
# ==================================================================
step "VSCode の設定を取り込み"
collect "VSCode settings.json" "$CONFIG_HOME/Code/User/settings.json" "$DOTDIR/vscode/settings.json"

# ==================================================================
# psmux
# ==================================================================
step "psmux の設定を取り込み"
collect "psmux.conf" "$CONFIG_HOME/psmux/psmux.conf" "$DOTDIR/psmux/psmux.conf"

# ==================================================================
# Claude Code
#   CLAUDE.md だけを取り込む。同じフォルダの .credentials.json などは
#   認証情報なので絶対に含めない。
# ==================================================================
step "Claude Code の指示書を取り込み"
collect "CLAUDE.md" "$HOME/.claude/CLAUDE.md" "$DOTDIR/claude/CLAUDE.md"

# Windows Terminal は Windows 専用のため、ここでは扱わない。

# ==================================================================
# 完了メッセージ
# ==================================================================
echo ""
echo "=== 完了 ==="
echo "次のコマンドで差分を確認してからコミットしてください:"
echo "  git -C \"$DOTDIR\" status"
echo "  git -C \"$DOTDIR\" diff"
