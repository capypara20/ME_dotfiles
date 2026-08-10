#!/usr/bin/env bash
# ==================================================================
# Linux 用 dotfiles インストーラ（コピー方式）
#
# やること:
#   リポジトリ内の設定ファイルを、各アプリが見る場所へ「コピー」する。
#
# 使い方:
#   git clone https://github.com/capypara20/dotfiles.git ~/dotfiles
#   cd ~/dotfiles
#   bash install.sh            # 配置する
#   bash install.sh --dry-run  # 何が起きるか表示するだけ
#
# 逆方向（今のPCの設定をリポジトリに取り込む）は sync.sh を使う。
# ==================================================================

set -eu

# このスクリプトが置かれている場所 = リポジトリの場所
DOTDIR="$(cd "$(dirname "$0")" && pwd)"

# 設定ファイルの置き場所（Windows 側と揃える）
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

# --dry-run が付いていたら、実際の変更はしない
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
# 既存ファイルを日付つきの名前に退避してから、コピーで上書きする
# 引数: 表示名 コピー元 コピー先
# ------------------------------------------------------------------
deploy() {
  label="$1"; src="$2"; dst="$3"

  if [ ! -e "$src" ]; then
    skip "$label : リポジトリに $src が無いので飛ばします"
    return
  fi

  info "$label : $src"
  info "       -> $dst"

  # 既存を退避
  if [ -e "$dst" ]; then
    backup="$dst.bak-$(date +%Y%m%d-%H%M%S)"
    info "退避: $dst -> $backup"
    [ "$DRYRUN" -eq 0 ] && mv "$dst" "$backup"
  fi

  if [ "$DRYRUN" -eq 0 ]; then
    mkdir -p "$(dirname "$dst")"
    # -r はフォルダ用。ファイルでもそのまま使える。
    cp -r "$src" "$dst"
  fi
  ok "$label"
}

# ==================================================================
# nvim
# ==================================================================
step "nvim の設定を配置"
deploy "nvim" "$DOTDIR/nvim" "$CONFIG_HOME/nvim"

# WSL では IME を切るのに Windows の zenhan.exe を呼ぶ。
# Linux 側へコピーされた exe は実行権限が落ちていることがあるので付け直す。
if [ "$DRYRUN" -eq 0 ] && [ -d "$CONFIG_HOME/nvim/bin" ]; then
  chmod +x "$CONFIG_HOME"/nvim/bin/*.exe 2>/dev/null || true
  ok "zenhan.exe に実行権限を付与"
fi

# ==================================================================
# bash
# ==================================================================
step "bash の設定を配置"
deploy ".bashrc" "$DOTDIR/bash/.bashrc" "$HOME/.bashrc"

# ==================================================================
# PowerShell（Linux に pwsh を入れている場合だけ）
# ==================================================================
step "PowerShell プロファイルを配置"
if command -v pwsh >/dev/null 2>&1; then
  deploy "PowerShell profile" \
    "$DOTDIR/powershell/profile.ps1" \
    "$CONFIG_HOME/powershell/Microsoft.PowerShell_profile.ps1"
else
  skip "pwsh が入っていないので飛ばします"
fi

# ==================================================================
# VSCode（インストール済みの場合だけ）
# ==================================================================
step "VSCode の設定を配置"
if [ -d "$CONFIG_HOME/Code/User" ]; then
  deploy "VSCode settings.json" "$DOTDIR/vscode/settings.json" "$CONFIG_HOME/Code/User/settings.json"
else
  skip "VSCode が見つからないので飛ばします"
fi

# ==================================================================
# psmux
# ==================================================================
step "psmux の設定を配置"
deploy "psmux.conf" "$DOTDIR/psmux/psmux.conf" "$CONFIG_HOME/psmux/psmux.conf"

# ==================================================================
# Claude Code の指示書
# ==================================================================
step "Claude Code の指示書を配置"
deploy "CLAUDE.md" "$DOTDIR/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"

# Windows Terminal は Windows 専用のため、ここでは扱わない。

# ==================================================================
# 完了メッセージ
# ==================================================================
echo ""
echo "=== 完了 ==="
echo "・上書き前のファイルは *.bak-日付 という名前で同じ場所に残しています"
echo "・新しいターミナルを開くと設定が反映されます"
echo "・設定を変更したあとは  bash sync.sh  でリポジトリに取り込んでください"
