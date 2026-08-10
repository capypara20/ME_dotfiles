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
#   Windows PowerShell 5.1 と PowerShell 7 では $PROFILE の場所が違う。
#   両方に本体をコピーすると同じ内容が2枚でき、片方だけ古くなって
#   「pwsh でだけ設定が効かない」事故が起きる。
#   そこで本体は1枚だけ置き、$PROFILE の場所には「本体を読むだけ」の
#   スタブを置く。
#
#     ~\.config\powershell\profile.ps1        ← 本体（中身はここだけ）
#            ↑ 読む              ↑ 読む
#     Documents\WindowsPowerShell\   Documents\PowerShell\
#       Microsoft.PowerShell_profile.ps1（スタブ）
#
#   Documents は OneDrive に移動されている場合があるので、決め打ちせず
#   Windows に「本当の Documents はどこ？」と聞く。
$Docs        = [Environment]::GetFolderPath("MyDocuments")
$ProfileMain = Join-Path $ConfigHome "powershell\profile.ps1"
$ProfileStubs = @(
  (Join-Path $Docs "PowerShell\Microsoft.PowerShell_profile.ps1")         # PowerShell 7 (pwsh)
  (Join-Path $Docs "WindowsPowerShell\Microsoft.PowerShell_profile.ps1")  # Windows PowerShell 5.1
)

# VSCode
$VscodeDst = Join-Path $env:APPDATA "Code\User\settings.json"

# Windows Terminal:
#   Store版・Preview版・非Store版で場所が違うので、候補を順に調べて
#   「実際にフォルダがある版」に配置する。
$WtCandidates = @(
  (Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json")
  (Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json")
  (Join-Path $env:LOCALAPPDATA "Microsoft\Windows Terminal\settings.json")
)

# psmux（ターミナル分割ツール）
$PsmuxDst = Join-Path $ConfigHome "psmux\psmux.conf"

# Claude Code の指示書
$ClaudeDst = Join-Path $HOME ".claude\CLAUDE.md"

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

# (a) 本体を ~\.config\powershell\profile.ps1 へ
Deploy "PowerShell profile 本体" (Join-Path $DotDir "powershell\profile.ps1") $ProfileMain $false

# (b) 5.1 用 / 7 用の $PROFILE には「本体を読むだけ」のスタブを置く
$StubBody = @'
# ==================================================================
# このファイルは「本体を呼び出すだけ」のファイルです。
#
# ★ 設定を書き足すときは、下の本体のほうを編集してください ★
#     本体: ~\.config\powershell\profile.ps1
#
# Windows PowerShell 5.1 と PowerShell 7 (pwsh) では $PROFILE の
# 置き場所が違うため、両方からこの1行で同じ本体を読み込んでいます。
#
# ※ このファイルは install.ps1 が自動生成します。直接編集しないでください。
# ==================================================================

$SharedProfile = Join-Path $HOME ".config\powershell\profile.ps1"
if (Test-Path $SharedProfile) {
  . $SharedProfile
} else {
  Write-Warning "プロファイル本体が見つかりません: $SharedProfile"
}
'@

foreach ($t in $ProfileStubs) {
  Info "PowerShell profile スタブ -> $t"
  Backup-IfExists $t
  if (-not $DryRun) {
    $parent = Split-Path -Parent $t
    if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Force -Path $parent | Out-Null }
    # 日本語コメントを含むので UTF-8 の「BOM付き」で保存する。
    # BOM が無いと Windows PowerShell 5.1 が Shift-JIS と誤読して構文エラーになる。
    $enc = New-Object System.Text.UTF8Encoding($true)
    [System.IO.File]::WriteAllText($t, $StubBody, $enc)
  }
  Ok "PowerShell profile スタブ"
}

Step "VSCode の設定を配置"
if (Test-Path (Split-Path -Parent $VscodeDst)) {
  Deploy "VSCode settings.json" (Join-Path $DotDir "vscode\settings.json") $VscodeDst $false
} else {
  Skip "VSCode が見つからないので飛ばします（$VscodeDst）"
}

Step "Windows Terminal の設定を配置"
# 判定は「settings.json が実際にあるか」で行う。
# フォルダの有無で判定すると、WSL のプロファイル断片が置かれる
# 「Local\Microsoft\Windows Terminal」を誤って版と見なしてしまうため。
$wtTargets = @($WtCandidates | Where-Object { Test-Path $_ })

if ($wtTargets.Count -eq 0) {
  # 一度も起動していないPCには settings.json が無い。
  # その場合は Store 版のフォルダがあれば、そこに新規作成する。
  $wtStoreDir = Join-Path $env:LOCALAPPDATA "Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
  if (Test-Path $wtStoreDir) {
    $wtTargets = @((Join-Path $wtStoreDir "settings.json"))
  }
}

foreach ($wt in $wtTargets) {
  Deploy "Windows Terminal settings.json" (Join-Path $DotDir "wterminal\settings.json") $wt $false
}

if ($wtTargets.Count -eq 0) {
  Skip "Windows Terminal が見つからないので飛ばします"
} else {
  Info "※ Windows Terminal を開いたままだと、閉じるときに古い設定へ戻ることがあります"
  Info "   反映されないときは Windows Terminal を再起動してください"
}

Step "psmux の設定を配置"
Deploy "psmux.conf" (Join-Path $DotDir "psmux\psmux.conf") $PsmuxDst $false

Step "Claude Code の指示書を配置"
Deploy "CLAUDE.md" (Join-Path $DotDir "claude\CLAUDE.md") $ClaudeDst $false

# ==================================================================
# 完了メッセージ
# ==================================================================
Write-Host "`n=== 完了 ===" -ForegroundColor Cyan
Write-Host "・上書き前のファイルは *.bak-日付 という名前で同じ場所に残しています"
Write-Host "・新しいターミナルを開くと設定が反映されます"
Write-Host "・設定を変更したあとは  .\sync.ps1  でリポジトリに取り込んでください"
