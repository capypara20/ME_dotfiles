# ==================================================================
# Windows 用 dotfiles 収集スクリプト（install.ps1 の逆方向）
#
# やること:
#   今このPCで使っている設定ファイルを、dotfiles リポジトリへコピーし直す。
#   （コピー方式なので、設定を編集しただけではリポジトリに反映されないため）
#
# 使い方:
#   cd "$HOME\dotfiles"
#   .\sync.ps1            # 取り込む
#   .\sync.ps1 -DryRun    # 何が起きるか表示するだけ
#   git diff              # 取り込んだ差分を確認
#   git add -A; git commit -m "設定を更新"; git push
# ==================================================================

param(
  [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$DotDir = $PSScriptRoot

function Info($msg) { Write-Host "  $msg" }
function Step($msg) { Write-Host "`n[$msg]" -ForegroundColor Cyan }
function Ok($msg)   { Write-Host "  OK   $msg" -ForegroundColor Green }
function Skip($msg) { Write-Host "  --   $msg" -ForegroundColor DarkGray }

if ($DryRun) {
  Write-Host "*** DryRun モード: 実際には何も変更しません ***" -ForegroundColor Yellow
}

$ConfigHome = if ($env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME } else { Join-Path $HOME ".config" }
$Docs       = [Environment]::GetFolderPath("MyDocuments")

# --- 取り込み用の共通処理 --------------------------------------------
# フォルダの場合、リポジトリ側を一度消してからコピーする。
# （そうしないと「PCで消したファイル」がリポジトリに残り続けるため）
function Collect($label, $src, $dst, $isDir) {
  if (-not (Test-Path $src)) {
    Skip "$label : $src が無いので飛ばします"
    return
  }
  Info "$label : $src"
  Info "       -> $dst"
  if (-not $DryRun) {
    if ($isDir) {
      if (Test-Path $dst) { Remove-Item -Path $dst -Recurse -Force }
      Copy-Item -Path $src -Destination $dst -Recurse -Force
    } else {
      $parent = Split-Path -Parent $dst
      if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
      Copy-Item -Path $src -Destination $dst -Force
    }
  }
  Ok $label
}

# ==================================================================
# nvim
# ==================================================================
Step "nvim の設定を取り込み"
Collect "nvim" (Join-Path $ConfigHome "nvim") (Join-Path $DotDir "nvim") $true

# ==================================================================
# PowerShell プロファイル
#   本体は ~\.config\powershell\profile.ps1 の1枚だけ。
#   Documents 配下の2つ（5.1用 / 7用）は「本体を呼ぶだけ」のスタブなので
#   絶対に取り込まない。取り込むとリポジトリの設定が丸ごと消える。
# ==================================================================
Step "PowerShell プロファイルを取り込み"

# 中身が本物のプロファイルか判定する。
#   × 空ファイル       … Windows が自動で作ることがある
#   × スタブ           … 本体を dot-source するだけの十数行
# どちらも取り込むとリポジトリ側の設定が消えるため、弾く。
function Test-IsRealProfile($path) {
  if (-not $path) { return $false }
  if (-not (Test-Path $path)) { return $false }
  $raw = Get-Content -Path $path -Raw -ErrorAction SilentlyContinue
  if (-not $raw -or $raw.Trim().Length -eq 0) { return $false }
  if ($raw -match '\$SharedProfile') { return $false }
  return $true
}

$ProfileSrc = Join-Path $ConfigHome "powershell\profile.ps1"

if (-not (Test-IsRealProfile $ProfileSrc)) {
  # 旧構成のPC向けの保険。本体がまだ無ければ Documents 側から拾う。
  $ProfileSrc = @(
    (Join-Path $Docs "PowerShell\Microsoft.PowerShell_profile.ps1")
    (Join-Path $Docs "WindowsPowerShell\Microsoft.PowerShell_profile.ps1")
  ) |
    Where-Object { Test-IsRealProfile $_ } |
    Sort-Object { (Get-Item $_).LastWriteTime } -Descending |
    Select-Object -First 1
}

if ($ProfileSrc) {
  Collect "PowerShell profile" $ProfileSrc (Join-Path $DotDir "powershell\profile.ps1") $false
} else {
  Skip "本体のプロファイルが見つかりません（空／スタブは取り込みません）"
}

# ==================================================================
# VSCode
# ==================================================================
Step "VSCode の設定を取り込み"
Collect "VSCode settings.json" (Join-Path $env:APPDATA "Code\User\settings.json") (Join-Path $DotDir "vscode\settings.json") $false

# ==================================================================
# Windows Terminal
#   Store版・Preview版・非Store版のうち、実際にファイルがある版から取り込む。
# ==================================================================
Step "Windows Terminal の設定を取り込み"
$WtCandidates = @(
  (Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json")
  (Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json")
  (Join-Path $env:LOCALAPPDATA "Microsoft\Windows Terminal\settings.json")
)
$wtSrc = $WtCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if ($wtSrc) {
  Collect "Windows Terminal settings.json" $wtSrc (Join-Path $DotDir "wterminal\settings.json") $false
} else {
  Skip "Windows Terminal の設定が見つかりません"
}

# ==================================================================
# psmux
# ==================================================================
Step "psmux の設定を取り込み"
Collect "psmux.conf" (Join-Path $ConfigHome "psmux\psmux.conf") (Join-Path $DotDir "psmux\psmux.conf") $false

# ==================================================================
# Claude Code
#   CLAUDE.md だけを取り込む。同じフォルダにある .credentials.json などは
#   認証情報なので絶対に含めない。
# ==================================================================
Step "Claude Code の指示書を取り込み"
Collect "CLAUDE.md" (Join-Path $HOME ".claude\CLAUDE.md") (Join-Path $DotDir "claude\CLAUDE.md") $false

# ==================================================================
# scoop のアプリ一覧
#   scoop export はバージョン番号まで書き出すが、それを残すと
#   新しいPCで「古いバージョン」を入れようとしてしまう。
#   そこで Name と Source だけに絞って保存する。
#   グローバルインストール分（管理者権限が必要）も除外する。
# ==================================================================
Step "scoop のアプリ一覧を取り込み"
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
  Skip "scoop が見つかりません"
} else {
  $export = scoop export | ConvertFrom-Json

  $buckets = @($export.buckets | ForEach-Object {
    [ordered]@{ Name = $_.Name; Source = $_.Source }
  })
  $apps = @($export.apps |
    Where-Object { $_.Info -notlike "*Global install*" } |
    ForEach-Object { [ordered]@{ Name = $_.Name; Source = $_.Source; Info = "" } })

  $out = [ordered]@{ buckets = $buckets; apps = $apps }
  $json = $out | ConvertTo-Json -Depth 5

  $AppsJson = Join-Path $DotDir "scoop\scoop-apps.json"
  Info "アプリ $($apps.Count) 個 / バケット $($buckets.Count) 個"
  Info "       -> $AppsJson"
  if (-not $DryRun) {
    # BOM なし UTF-8 で保存（scoop import が確実に読めるように）
    $enc = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($AppsJson, $json, $enc)
  }
  Ok "scoop-apps.json"
}

# ==================================================================
# 完了メッセージ
# ==================================================================
Write-Host "`n=== 完了 ===" -ForegroundColor Cyan
Write-Host "次のコマンドで差分を確認してからコミットしてください:"
Write-Host "  git -C `"$DotDir`" status"
Write-Host "  git -C `"$DotDir`" diff"
