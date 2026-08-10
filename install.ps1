# ==================================================================
# Windows 用 dotfiles インストーラ（コピー方式）
#
# やること:
#   (1) XDG_CONFIG_HOME を設定（未設定なら ~\.config）
#   (2) scoop 本体を入れる（未導入なら）→ バケット追加 → アプリ一括install
#   (3) リポジトリ内の設定ファイルを、各アプリが見る場所へ「コピー」する
#
# 使い方:
#   git clone https://github.com/capypara20/dotfiles.git "$HOME\dotfiles"
#   cd "$HOME\dotfiles"
#   .\install.ps1              # 全部やる
#   .\install.ps1 -SkipScoop   # 設定ファイルのコピーだけ
#   .\install.ps1 -DryRun      # 何が起きるか表示するだけ（実際には変更しない）
#
# 逆方向（今のPCの設定をリポジトリに取り込む）は sync.ps1 を使う。
# ==================================================================

param(
  [switch]$SkipScoop,   # scoop 関連をまるごと飛ばす
  [switch]$DryRun       # 予行演習（表示するだけ）
)

$ErrorActionPreference = "Stop"

# このスクリプトが置かれている場所 = リポジトリの場所
$DotDir = $PSScriptRoot

# 見やすいログ用の小さな関数
function Info($msg) { Write-Host "  $msg" }
function Step($msg) { Write-Host "`n[$msg]" -ForegroundColor Cyan }
function Ok($msg)   { Write-Host "  OK   $msg" -ForegroundColor Green }
function Skip($msg) { Write-Host "  --   $msg" -ForegroundColor DarkGray }

if ($DryRun) {
  Write-Host "*** DryRun モード: 実際には何も変更しません ***" -ForegroundColor Yellow
}

# ==================================================================
# (1) XDG_CONFIG_HOME
#     Linux と同じ「~/.config」に設定ファイルを集めるための環境変数。
#     nvim はこれを見て設定を探すので、Win/Linux で同じ場所に置ける。
# ==================================================================
Step "XDG_CONFIG_HOME の確認"

if ($env:XDG_CONFIG_HOME) {
  Skip "設定済み: $env:XDG_CONFIG_HOME"
} else {
  $xdg = Join-Path $HOME ".config"
  Info "未設定なので $xdg を設定します（ユーザー環境変数）"
  if (-not $DryRun) {
    [Environment]::SetEnvironmentVariable("XDG_CONFIG_HOME", $xdg, "User")
    $env:XDG_CONFIG_HOME = $xdg   # 今のセッションにも反映
  }
  Ok "XDG_CONFIG_HOME = $xdg"
  Info "※ 新しく開くターミナルから有効になります"
}

$ConfigHome = if ($env:XDG_CONFIG_HOME) { $env:XDG_CONFIG_HOME } else { Join-Path $HOME ".config" }

# ==================================================================
# (2) scoop（パッケージマネージャ）
# ==================================================================
if ($SkipScoop) {
  Step "scoop"
  Skip "-SkipScoop が指定されたので飛ばします"
} else {
  Step "scoop 本体"
  if (Get-Command scoop -ErrorAction SilentlyContinue) {
    Skip "インストール済み"
  } else {
    Info "見つからないのでインストールします..."
    if (-not $DryRun) {
      Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
      Invoke-RestMethod get.scoop.sh | Invoke-Expression
    }
    Ok "scoop を導入しました"
  }

  Step "scoop バケット + アプリ"
  $AppsJson = Join-Path $DotDir "scoop\scoop-apps.json"
  if (-not (Test-Path $AppsJson)) {
    Skip "scoop-apps.json が無いので飛ばします"
  } else {
    # バケット（アプリの取り寄せ先リポジトリ）を先に追加しておく
    $data = Get-Content $AppsJson -Raw | ConvertFrom-Json
    $installed = @(scoop bucket list | ForEach-Object { $_.Name })
    foreach ($b in $data.buckets) {
      if ($installed -contains $b.Name) {
        Skip "bucket $($b.Name)"
      } else {
        Info "bucket 追加: $($b.Name)"
        if (-not $DryRun) { scoop bucket add $b.Name $b.Source }
      }
    }
    # アプリ一括インストール（入っているものは scoop 側でスキップされる）
    Info "アプリを一括インストールします（時間がかかります）"
    if (-not $DryRun) { scoop import $AppsJson }
    Ok "scoop アプリの処理が終わりました"
  }
}

# ==================================================================
# (3) 設定ファイルのコピー
# ==================================================================

# --- 配置先のパスを決める --------------------------------------------
# nvim: XDG_CONFIG_HOME\nvim
$NvimDst = Join-Path $ConfigHome "nvim"

# PowerShell プロファイル:
#   Documents フォルダは OneDrive に移動されている場合があるので、
#   決め打ちせず Windows に「本当の Documents はどこ？」と聞く。
$Docs = [Environment]::GetFolderPath("MyDocuments")
$ProfileTargets = @(
  (Join-Path $Docs "PowerShell\Microsoft.PowerShell_profile.ps1")         # PowerShell 7 (pwsh)
  (Join-Path $Docs "WindowsPowerShell\Microsoft.PowerShell_profile.ps1")  # Windows PowerShell 5.1
)

# VSCode
$VscodeDst = Join-Path $env:APPDATA "Code\User\settings.json"

# --- コピー用の共通処理 ----------------------------------------------
# 既存ファイルは消さずに、日付つきの名前へ退避してから上書きする。
function Backup-IfExists($path) {
  if (Test-Path $path) {
    $stamp  = Get-Date -Format "yyyyMMdd-HHmmss"
    $backup = "$path.bak-$stamp"
    Info "退避: $path -> $backup"
    if (-not $DryRun) { Move-Item -Path $path -Destination $backup -Force }
  }
}

function Deploy($label, $src, $dst, $isDir) {
  if (-not (Test-Path $src)) {
    Skip "$label : リポジトリに $src が無いので飛ばします"
    return
  }
  Info "$label : $src"
  Info "       -> $dst"
  Backup-IfExists $dst
  if (-not $DryRun) {
    $parent = Split-Path -Parent $dst
    if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
    if ($isDir) {
      Copy-Item -Path $src -Destination $dst -Recurse -Force
    } else {
      Copy-Item -Path $src -Destination $dst -Force
    }
  }
  Ok $label
}

Step "nvim の設定を配置"
Deploy "nvim" (Join-Path $DotDir "nvim") $NvimDst $true

Step "PowerShell プロファイルを配置"
foreach ($t in $ProfileTargets) {
  Deploy "PowerShell profile" (Join-Path $DotDir "powershell\profile.ps1") $t $false
}

Step "VSCode の設定を配置"
if (Test-Path (Split-Path -Parent $VscodeDst)) {
  Deploy "VSCode settings.json" (Join-Path $DotDir "vscode\settings.json") $VscodeDst $false
} else {
  Skip "VSCode が見つからないので飛ばします（$VscodeDst）"
}

# ==================================================================
# 完了メッセージ
# ==================================================================
Write-Host "`n=== 完了 ===" -ForegroundColor Cyan
Write-Host "・上書き前のファイルは *.bak-日付 という名前で同じ場所に残しています"
Write-Host "・新しいターミナルを開くと設定が反映されます"
Write-Host "・設定を変更したあとは  .\sync.ps1  でリポジトリに取り込んでください"
