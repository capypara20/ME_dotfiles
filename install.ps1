# ==================================================================
# Windows用 dotfiles インストーラ
#
# 役割:
#   1) この環境の「プロファイル」(work / private)を決める
#   2) 共通設定・OS固有設定・プロファイル固有設定を、固定パス
#      （$PROFILE, %LOCALAPPDATA%\nvim など）へシンボリックリンクで配置する
#
# 使い方: 開発者モード or 管理者の PowerShell で
#   $env:DOTFILES_PROFILE = "work"; .\install.ps1
#   （未指定なら ~/.dotfiles-profile を見る／対話で質問）
# ==================================================================
$ErrorActionPreference = "Stop"

# このスクリプトが置かれている場所（= リポジトリの場所）
$DotDir = $PSScriptRoot
$ProfileFile = Join-Path $HOME ".dotfiles-profile"

# ------------------------------------------------------------------
# 1) プロファイルの決定
#    優先順位: 環境変数 DOTFILES_PROFILE > ~/.dotfiles-profile > 対話入力
#    ※ $PROFILE は PowerShell の予約変数なので $Prof という名前にする
# ------------------------------------------------------------------
$Prof = $env:DOTFILES_PROFILE
if (-not $Prof -and (Test-Path $ProfileFile)) {
  $Prof = (Get-Content $ProfileFile -Raw).Trim()
}
while ($Prof -ne "work" -and $Prof -ne "private") {
  $Prof = Read-Host "この環境のプロファイルは？ [work/private]"
}
Set-Content -Path $ProfileFile -Value $Prof -NoNewline
Write-Host "プロファイル: $Prof"

# ------------------------------------------------------------------
# 2) リンク用ヘルパー
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
# 3) 配置（増えたらここに Link 行を1つ足すだけ）
# ------------------------------------------------------------------

# (a) OS固有: PowerShell プロファイル（まだ無ければ自動スキップ）
Link "$DotDir\windows\profile.ps1" $PROFILE

# (b) 共通: neovim 設定ディレクトリまるごと
Link "$DotDir\shared\nvim" "$env:LOCALAPPDATA\nvim"

# (c) プロファイル固有: neovim の差分入口 profile.lua
Link "$DotDir\profiles\$Prof\nvim\profile.lua" "$DotDir\shared\nvim\lua\profile.lua"

Write-Host "完了！(profile=$Prof)"
