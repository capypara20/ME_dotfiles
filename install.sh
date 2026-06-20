#!/bin/bash
# ==================================================================
# Linux用 dotfiles インストーラ
#
# 役割: 共通設定(shared/) と OS固有設定(linux/) を、OSが決め打ちで見る
#       固定パス（~/.bashrc, ~/.config/nvim など）へシンボリックリンクで配置する。
#
#       環境ごとの差分は git では管理せず、各設定が読み込む
#       「ローカル上書きファイル(*.local など, git管理外)」に置く方針。
#       → 会社支給PCのように push できない(clone専用)環境でも問題なく使える。
#
# 使い方: bash install.sh
# ==================================================================
set -euo pipefail

# このスクリプトが置かれている場所（= リポジトリの場所）
DOTDIR="$(cd "$(dirname "$0")" && pwd)"

# ------------------------------------------------------------------
# リンク用ヘルパー: src（リポジトリ内の実体）を dst（固定パス）へ
# ------------------------------------------------------------------
link() {
  local src="$1" dst="$2"
  # 元ファイルが無ければ黙ってスキップ（設定を少しずつ増やせるように）
  if [ ! -e "$src" ]; then
    echo "スキップ(無し): $src"
    return
  fi
  mkdir -p "$(dirname "$dst")"
  # 既存の「実体」（リンクでない本物）があれば .bak へ退避（安全策）
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "$dst.bak"
    echo "退避: $dst → $dst.bak"
  fi
  # -n: dst がディレクトリへのリンクでも中へ潜らず置き換える（nvim等の対策）
  ln -sfn "$src" "$dst"
  echo "リンク: $dst → $src"
}

# ------------------------------------------------------------------
# 配置（設定が増えたら link を1行足すだけ）
# ------------------------------------------------------------------
# OS固有: シェル
link "$DOTDIR/linux/.bashrc" "$HOME/.bashrc"

# 共通: neovim / tmux / git
link "$DOTDIR/shared/nvim" "$HOME/.config/nvim"
link "$DOTDIR/shared/tmux/tmux.conf" "$HOME/.tmux.conf"
link "$DOTDIR/shared/git/gitconfig" "$HOME/.gitconfig"

echo ""
echo "完了！"
echo "このマシンだけの差分は *.local に置いてください（雛形: *.example）。例:"
echo "  cp $DOTDIR/shared/nvim/lua/local.lua.example $DOTDIR/shared/nvim/lua/local.lua"
echo "  cp $DOTDIR/shared/git/local.gitconfig.example ~/.config/git/local.gitconfig"
