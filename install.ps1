# ==================================================================
# Windows用 dotfiles インストーラ
#
# 役割: 共通設定(shared/) と OS固有設定(windows/) を、固定パス
#       （$PROFILE, %LOCALAPPDATA%\nvim など）へシンボリックリンクで配置する。
#
#       環境ごとの差分は git では管理せず、各設定が読み込む
#       「ローカル上書きファイル(*.local など, git管理外)」に置く方針。
#
# 使い方: 開発者モード or 管理者の PowerShell で  .\install.ps1
# ==================================================================
$ErrorActionPreference = "Stop"

# このスクリプトが置かれている場所（= リポジトリの場所）
$DotDir = $PSScriptRoot

# ------------------------------------------------------------------
# リンク用ヘルパー
# ------------------------------------------------------------------
function Link($src, $dst) {
  if (-not (Test-Path $src)) {
    Write-Host "スキップ(無し): $src"
    return
  }
  $parent = Split-Path $dst -Parent
  if ($parent -and -not (Test-Path $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
  }
  # 既存の「実体」（リンクでない本物）があれば .bak へ退避
  if ((Test-Path $dst) -and -not ((Get-Item $dst).LinkType)) {
    Rename-Item $dst "$dst.bak"
    Write-Host "退避: $dst -> $dst.bak"
  }
  New-Item -ItemType SymbolicLink -Path $dst -Target $src -Force | Out-Null
  Write-Host "リンク: $dst -> $src"
}

# ------------------------------------------------------------------
# 配置（増えたら Link を1行足すだけ）
#   ※ tmux は Unix 専用のため Windows では配置しない
# ------------------------------------------------------------------
# OS固有: PowerShell プロファイル（まだ無ければ自動スキップ）
Link "$DotDir\windows\profile.ps1" $PROFILE

# 共通: neovim / git
Link "$DotDir\shared\nvim" "$env:LOCALAPPDATA\nvim"
Link "$DotDir\shared\git\gitconfig" "$HOME\.gitconfig"

Write-Host ""
Write-Host "完了！ このマシンだけの差分は *.local に置いてください（雛形: *.example）。例:"
Write-Host "  copy $DotDir\shared\git\local.gitconfig.example $HOME\.config\git\local.gitconfig"
