# ==================================================================
# PowerShell プロファイル（dotfiles で管理）
#
# 配置先: $PROFILE
#   - PowerShell 7 : ~\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
#   - Windows PS   : ~\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
#
# このPC固有の設定は、同じフォルダの profile.local.ps1 に書く。
# （そちらは Git 管理外なので、他のPCに持っていかれない）
# ==================================================================

# ------------------------------------------------------------------
# 環境変数
# ------------------------------------------------------------------
# 設定ファイルの置き場所を Linux と揃える（~\.config）
if (-not $env:XDG_CONFIG_HOME) {
  $env:XDG_CONFIG_HOME = Join-Path $HOME ".config"
}

# git などが開くエディタを nvim に
if (Get-Command nvim -ErrorAction SilentlyContinue) {
  $env:EDITOR = "nvim"
}

# ------------------------------------------------------------------
# エイリアス / 簡易関数
# ------------------------------------------------------------------
function ll { Get-ChildItem -Force @args }          # 隠しファイルも含めて一覧
function la { Get-ChildItem -Force @args }
function .. { Set-Location .. }
function ... { Set-Location ..\.. }

function g { git @args }                            # g status のように使える
function gs { git status --short --branch }
function gl { git log --oneline --graph --decorate -20 }

function v { nvim @args }                           # v ファイル名 で nvim 起動

# dotfiles フォルダへ一瞬で移動
function dot { Set-Location (Join-Path $HOME "dotfiles") }

# ------------------------------------------------------------------
# PSReadLine（入力補助）
#   ※ 古い PowerShell では一部オプションが無いので try で囲む
# ------------------------------------------------------------------
if (Get-Module -ListAvailable -Name PSReadLine) {
  try {
    # 過去の入力履歴からグレー文字で候補を出す
    Set-PSReadLineOption -PredictionSource History -ErrorAction Stop
  } catch {
    # PSReadLine が古い場合は何もしない
  }
  # Tab キーで候補を一覧から選べるようにする
  Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete
  # ↑↓ キーで「入力済みの文字で始まる履歴」だけを辿る
  Set-PSReadLineKeyHandler -Key UpArrow   -Function HistorySearchBackward
  Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
}

# ------------------------------------------------------------------
# このPC専用の設定を読み込む（あれば）
#   例: 会社PCだけのプロキシ設定、個人PCだけのパス追加 など
# ------------------------------------------------------------------
$LocalProfile = Join-Path (Split-Path -Parent $PROFILE) "profile.local.ps1"
if (Test-Path $LocalProfile) {
  . $LocalProfile
}
