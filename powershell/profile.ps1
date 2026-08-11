# ==================================================================
# PowerShell プロファイル 本体（dotfiles で管理）
#
# ★中身を編集するのはこのファイルだけ。★
#
#   dotfiles\powershell\profile.ps1     ← 今このファイル（Git 管理）
#            │ install.ps1 がコピーする
#            ├─────────────────────┐
#   Documents\WindowsPowerShell\    Documents\PowerShell\
#        profile.ps1                     profile.ps1
#    = Windows PowerShell 5.1        = PowerShell 7 (pwsh)
#                                      ※ pwsh があるPCだけ
#
# 置き場所について:
#   PowerShell は 5.1 と 7 で $PROFILE の場所が違うため、両方に同じ
#   ファイルをコピーしている。どちらも $PROFILE.CurrentUserAllHosts
#   （= profile.ps1）なので、コンソール以外のホストでも読まれる。
#
#   実体が2枚あるので、片方を直接編集したら sync.ps1 で取り込み、
#   install.ps1 で両方に配り直すこと。
#
# このPC固有の設定は ~\.config\powershell\profile.local.ps1 に書く。
# （そちらは Git 管理外なので、他のPCに持っていかれない）
# ==================================================================

# ------------------------------------------------------------------
# 環境変数
# ------------------------------------------------------------------
# 設定ファイルの置き場所を Linux と揃える（~\.config）
if (-not $env:XDG_CONFIG_HOME) {
  $env:XDG_CONFIG_HOME = Join-Path $HOME ".config"
}

# git などが開くエディタを nvim に。
#   git は core.editor → VISUAL → EDITOR の順に探すので、この1行が無いと
#   git commit（-m なし）で vim が開いてしまう。
#   ※ 以前は Get-Command で nvim の有無を調べていたが、PATH を全部
#      走査するため 240ms もかかっていた。nvim は scoop-apps.json に
#      入っていて必ず入るので、調べずに代入する。
$env:EDITOR = "nvim"

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
#   ※ Get-Module -ListAvailable は全モジュールフォルダを探しに行って
#      遅い（40ms）。コンソールではプロファイルより先に PSReadLine が
#      読み込まれているので、「読み込み済みか」だけを見れば足りる。
# ------------------------------------------------------------------
if (Get-Module PSReadLine) {
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

# ==================================================================
# プロンプト（Linux 風の3行表示）
#
#   14:41:44 DESKTOP-0HEJ4UD@10.152.100.214 100%+ pwsh7.6
#   C:\Users\capypara20\.config\nvim  (main*)
#   (ｯ･ω･)ｯ
#
#   1行目 … 時刻 / マシン名@IP / バッテリー残量（末尾の + は充電中）
#            / 今のPowerShellの種類（pwsh = 7以降、PS = Windows 5.1）
#   2行目 … 今いるフォルダのフルパス / Git リポジトリなら (ブランチ名)
#            ブランチ名の後ろの * は「未コミットの変更あり」
#   3行目 … 顔文字。直前のコマンドが失敗したときだけ赤くなる
#
# ここから下はコンソール（普通のターミナル）専用。
#   このファイルは CurrentUserAllHosts なので、VSCode の PowerShell 拡張や
#   Windows PowerShell ISE からも読まれる。ISE は色指定（ANSI エスケープ）を
#   解釈できず記号の羅列になってしまうため、ホストを見て切り分ける。
#   上のエイリアスや関数はどのホストでも使える。
# ==================================================================
if ($Host.Name -eq 'ConsoleHost') {

  # ---- 好みで変えるところ ----
  $PromptFace      = '(ｯ･ω･)ｯ'   # 3行目の顔文字
  $PromptIpAlias   = 'Wi-Fi'      # IP を取るアダプタ名（ipconfig で一覧が見られる）
  $PromptShowDirty = $true        # Git の未コミット変更を * で出す（重ければ $false）
  $PromptColor     = $true        # 色を付ける（文字化けするなら $false）
  # ----------------------------

  # 顔文字などを正しく表示するため、コンソールの文字コードを UTF-8 にする
  [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

  # バッテリー取得用の .NET 機能（Get-CimInstance Win32_Battery より圧倒的に速い）
  try { Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop } catch { }

  # プロンプトが3行あることを PSReadLine に教える（表示崩れ防止）
  try { Set-PSReadLineOption -ExtraPromptLineCount 2 -ErrorAction Stop } catch { }

  # 色の定義（ANSI エスケープ）。毎回作ると遅いので起動時に1回だけ作る
  $PromptEsc = [char]27
  $PromptColors = @{
    reset   = "$PromptEsc[0m"
    dim     = "$PromptEsc[38;5;245m"   # グレー
    time    = "$PromptEsc[38;5;117m"   # 水色
    host    = "$PromptEsc[38;5;150m"   # 黄緑
    path    = "$PromptEsc[38;5;180m"   # 薄い橙
    git     = "$PromptEsc[38;5;176m"   # 紫
    face    = "$PromptEsc[38;5;217m"   # ピンク
    ok      = "$PromptEsc[38;5;114m"   # 緑
    warn    = "$PromptEsc[38;5;221m"   # 黄
    bad     = "$PromptEsc[38;5;203m"   # 赤
    core    = "$PromptEsc[38;5;39m"    # 青   … pwsh (PowerShell 7 以降)
    desktop = "$PromptEsc[38;5;214m"   # 橙   … Windows PowerShell 5.1
  }
  if (-not $PromptColor) {
    foreach ($k in @($PromptColors.Keys)) { $PromptColors[$k] = '' }
  }

  # --- 今動いているのが pwsh か Windows PowerShell かを判定 ---
  #     PSEdition は Core = pwsh (7以降) / Desktop = Windows PowerShell 5.1。
  #     起動時に1回決めておけば、プロンプト側は文字をつなぐだけで済む。
  $PromptPsTag = "{0}{1}.{2}" -f `
    $(if ($PSVersionTable.PSEdition -eq 'Core') { 'pwsh' } else { 'PS' }),
    $PSVersionTable.PSVersion.Major,
    $PSVersionTable.PSVersion.Minor
  $PromptPsTagColor = if ($PSVersionTable.PSEdition -eq 'Core') {
    $PromptColors.core
  } else {
    $PromptColors.desktop
  }

  # --- IP アドレス（毎回調べると遅いので60秒キャッシュする） ---
  #     ipconfig の出力を読むだけ。Get-NetIPAddress は裏で NetTCPIP モジュールを
  #     読み込むため初回に 550ms 前後かかるが、こちらは 30ms 程度で済む。
  #
  #     ipconfig の出力はこんな形:
  #       Wireless LAN adapter Wi-Fi:          ← 行頭が空白でなく、末尾が :
  #          IPv4 Address. . . . . . : 172.20.10.4
  #     「IPv4」は日本語版 Windows でも同じ綴りなので、そのまま探せる。
  $script:PromptIp     = $null
  $script:PromptIpTime = [datetime]::MinValue
  function Get-PromptIp {
    if (((Get-Date) - $script:PromptIpTime).TotalSeconds -lt 60) { return $script:PromptIp }

    $lines = ipconfig
    $ip = $null

    # (1) $PromptIpAlias（既定は Wi-Fi）のところだけを見る
    $inTarget = $false
    foreach ($line in $lines) {
      if ($line -match '^\S.*:\s*$') {
        # アダプタの見出し行。目的のアダプタかどうかを覚えておく
        $inTarget = $line -match [regex]::Escape($PromptIpAlias)
      } elseif ($inTarget -and $line -match 'IPv4.*?:\s*([\d\.]+)') {
        # 169.254.x.x は「IPアドレスが取れなかった」ときの仮の値なので除く
        if ($Matches[1] -notlike '169.254.*') { $ip = $Matches[1]; break }
      }
    }

    # (2) 見つからないとき（Wi-Fi を切っている等）は、使えそうな IPv4 を上から拾う
    if (-not $ip) {
      foreach ($line in $lines) {
        if ($line -match 'IPv4.*?:\s*([\d\.]+)' -and $Matches[1] -notlike '169.254.*') {
          $ip = $Matches[1]; break
        }
      }
    }

    if (-not $ip) { $ip = 'no-ip' }
    $script:PromptIp     = $ip
    $script:PromptIpTime = Get-Date
    return $ip
  }

  # --- バッテリー残量。デスクトップPCなど電池が無ければ $null を返す ---
  function Get-PromptBattery {
    try {
      $p = [System.Windows.Forms.SystemInformation]::PowerStatus
      if ($p.BatteryChargeStatus -band [System.Windows.Forms.BatteryChargeStatus]::NoSystemBattery) { return $null }
      $pct = [int][Math]::Round($p.BatteryLifePercent * 100)
      if ($pct -lt 0 -or $pct -gt 100) { return $null }
      return @{
        Percent = $pct
        Mark    = $(if ($p.PowerLineStatus -eq 'Online') { '+' } else { '' })
      }
    } catch { return $null }
  }

  # --- Git のブランチ名 ---
  #     .git フォルダを上へ辿って探し、HEAD ファイルを直接読む。
  #     git.exe を起動しないので速い（1ms 以下）。
  function Get-PromptGitBranch {
    if ($PWD.Provider.Name -ne 'FileSystem') { return $null }
    $path = $PWD.ProviderPath
    while ($path) {
      $gitPath = Join-Path $path '.git'
      if (Test-Path $gitPath) {
        # .git がファイルの場合、中身が本体の場所を指している（worktree / submodule）
        if (Test-Path $gitPath -PathType Leaf) {
          $first = Get-Content $gitPath -TotalCount 1
          if ($first -match '^gitdir:\s*(.+)$') { $gitPath = $Matches[1].Trim() } else { return $null }
        }
        $head = Join-Path $gitPath 'HEAD'
        if (-not (Test-Path $head)) { return $null }
        $line = (Get-Content $head -TotalCount 1).Trim()
        # 通常は "ref: refs/heads/main" のように書かれている
        if ($line -match '^ref:\s*refs/heads/(.+)$') { return $Matches[1] }
        # ブランチから外れている状態（detached HEAD）はコミットIDの先頭7桁
        return $line.Substring(0, [Math]::Min(7, $line.Length))
      }
      $parent = Split-Path $path -Parent
      if ([string]::IsNullOrEmpty($parent) -or $parent -eq $path) { break }
      $path = $parent
    }
    return $null
  }

  # --- 未コミットの変更があるか。ここだけ git.exe を呼ぶ（約50ms） ---
  function Test-PromptGitDirty {
    try {
      $out = & git --no-optional-locks status --porcelain 2>$null | Select-Object -First 1
      return [bool]$out
    } catch { return $false }
  }

  function prompt {
    # プロンプト内で色々実行すると $? と $LASTEXITCODE が壊れるので、先に退避する
    $lastOk   = $?
    $lastCode = $global:LASTEXITCODE

    $c = $PromptColors

    # 1行目: 時刻 / マシン名@IP / バッテリー / PowerShell の種類
    $line1 = "$($c.time)$(Get-Date -Format 'HH:mm:ss')$($c.reset) " +
             "$($c.host)$env:COMPUTERNAME$($c.dim)@$($c.host)$(Get-PromptIp)$($c.reset)"
    $bat = Get-PromptBattery
    if ($bat) {
      $bc = if ($bat.Percent -ge 50) { $c.ok } elseif ($bat.Percent -ge 20) { $c.warn } else { $c.bad }
      $line1 += " $bc$($bat.Percent)%$($bat.Mark)$($c.reset)"
    }
    $line1 += " $PromptPsTagColor$PromptPsTag$($c.reset)"

    # 2行目: フルパス / (ブランチ名)
    $line2 = "$($c.path)$($PWD.Path)$($c.reset)"
    $branch = Get-PromptGitBranch
    if ($branch) {
      $dirty = if ($PromptShowDirty -and (Test-PromptGitDirty)) { '*' } else { '' }
      $line2 += "  $($c.git)($branch$dirty)$($c.reset)"
    }

    # 3行目: 顔文字（直前のコマンドが失敗していたら赤くする）
    $faceColor = if ($lastOk) { $c.face } else { $c.bad }

    # 退避しておいた値を元に戻す
    $global:LASTEXITCODE = $lastCode

    "$line1`n$line2`n$faceColor$PromptFace$($c.reset) "
  }

}   # /if ConsoleHost

# ------------------------------------------------------------------
# このPC専用の設定を読み込む（あれば）
#   例: 会社PCだけのプロキシ設定、個人PCだけのパス追加 など
#
#   このファイル自体は 5.1 用と 7 用の2か所に置かれるが、PC固有設定まで
#   2枚に増えると管理しきれない。そのため置き場所は1か所に固定する。
# ------------------------------------------------------------------
$LocalProfile = Join-Path $HOME ".config\powershell\profile.local.ps1"
if (Test-Path $LocalProfile) {
  . $LocalProfile
}
