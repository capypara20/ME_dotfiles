#!/bin/bash
# ==================================================================
# Linux用 dotfiles インストーラ
#
# 役割:
#   1) この環境の「プロファイル」(work / private)を決める
#   2) 共通設定・OS固有設定・プロファイル固有設定を、OSが決め打ちで見る
#      固定パス（~/.bashrc, ~/.config/nvim など）へシンボリックリンクで配置する
#
# 使い方:
#   DOTFILES_PROFILE=work bash install.sh   # 環境変数で明示（おすすめ）
#   bash install.sh                          # 未指定なら ~/.dotfiles-profile を見る／対話で質問
# ==================================================================
set -euo pipefail

# このスクリプトが置かれている場所（= リポジトリの場所）を自動で割り出す
DOTDIR="$(cd "$(dirname "$0")" && pwd)"

# ------------------------------------------------------------------
# 1) プロファイルの決定
#    優先順位: 環境変数 DOTFILES_PROFILE > ~/.dotfiles-profile > 対話入力
# ------------------------------------------------------------------
PROFILE="${DOTFILES_PROFILE:-}"
PROFILE_FILE="$HOME/.dotfiles-profile"

if [ -z "$PROFILE" ] && [ -f "$PROFILE_FILE" ]; then
  PROFILE="$(tr -d '[:space:]' < "$PROFILE_FILE")"
fi

while [ "$PROFILE" != "work" ] && [ "$PROFILE" != "private" ]; do
  # 非対話実行（パイプ等）で未指定なら、無限ループを避けて終了する
  if [ ! -t 0 ]; then
    echo "プロファイル未指定です。例: DOTFILES_PROFILE=work bash install.sh" >&2
    exit 1
  fi
  printf "この環境のプロファイルは？ [work/private]: "
  read -r PROFILE
done

# 次回以降このマシンでは自動で使えるよう記録しておく
echo "$PROFILE" > "$PROFILE_FILE"
echo "プロファイル: $PROFILE"

# ------------------------------------------------------------------
# 2) リンク用ヘルパー
#    src（リポジトリ内の実体）を dst（OSが見る固定パス）へリンクする
# ------------------------------------------------------------------
link() {
  local src="$1" dst="$2"
  # 元ファイルが無ければ黙ってスキップ（設定を少しずつ増やせるように）
  if [ ! -e "$src" ]; then
    echo "スキップ(無し): $src"
    return
  fi
  # 配置先の親ディレクトリを用意
  mkdir -p "$(dirname "$dst")"
  # 既存の「実体」（リンクでない本物）があれば .bak へ退避（安全策）
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "$dst.bak"
    echo "退避: $dst → $dst.bak"
  fi
  # -n: dst がディレクトリへのリンクでも中に潜らず置き換える（nvim等の対策）
  ln -sfn "$src" "$dst"
  echo "リンク: $dst → $src"
}

# ------------------------------------------------------------------
# 3) 配置
#    設定ファイルが増えたら、ここに link 行を1つ足すだけ。
# ------------------------------------------------------------------

# (a) OS固有: シェル
link "$DOTDIR/linux/.bashrc" "$HOME/.bashrc"

# (b) 共通: neovim 設定ディレクトリまるごと
link "$DOTDIR/shared/nvim" "$HOME/.config/nvim"

# (c) プロファイル固有: neovim の差分入口 profile.lua
#     ~/.config/nvim は shared/nvim へのリンクなので、実体はリポジトリ内
#     （shared/nvim/lua/profile.lua）に作られる。これは .gitignore 済み。
link "$DOTDIR/profiles/$PROFILE/nvim/profile.lua" "$DOTDIR/shared/nvim/lua/profile.lua"

echo "完了！(profile=$PROFILE)"
