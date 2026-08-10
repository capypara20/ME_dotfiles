# dotfiles

Windows と Linux の両方で、同じ設定ファイルを使い回すためのリポジトリ。

新しいPCでは **クローン → スクリプトを1回実行** するだけで、
nvim・PowerShell・VSCode・scoop の環境が揃う。

---

## 管理しているもの

| フォルダ | 中身 | 配置先（Windows） | 配置先（Linux） |
|---|---|---|---|
| `nvim/` | Neovim の設定（LazyVim） | `%XDG_CONFIG_HOME%\nvim` | `~/.config/nvim` |
| `powershell/` | PowerShell プロファイル | `Documents\PowerShell\...profile.ps1`<br>`Documents\WindowsPowerShell\...profile.ps1` | `~/.config/powershell/...profile.ps1` |
| `vscode/` | VSCode の `settings.json` | `%APPDATA%\Code\User\settings.json` | `~/.config/Code/User/settings.json` |
| `scoop/` | scoop で入れるアプリ一覧 | （install.ps1 が読んで一括インストール） | — |
| `wterminal/` | Windows Terminal の `settings.json` | `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_*\LocalState\` | —（Windows 専用） |
| `psmux/` | `psmux.conf` | `%XDG_CONFIG_HOME%\psmux\` | `~/.config/psmux/` |
| `claude/` | Claude Code の `CLAUDE.md` | `~\.claude\CLAUDE.md` | `~/.claude/CLAUDE.md` |
| `bash/` | `.bashrc` | — | `~/.bashrc` |

---

## ディレクトリ構成

```
dotfiles/
├─ nvim/                 ← Windows / Linux 共通でそのまま使う
│   ├─ init.lua
│   ├─ lazy-lock.json    ← プラグインのバージョン固定ファイル
│   └─ lua/
│       ├─ config/
│       └─ plugins/
├─ powershell/
│   └─ profile.ps1
├─ vscode/
│   └─ settings.json
├─ scoop/
│   └─ scoop-apps.json
├─ wterminal/            ← Windows 専用
│   └─ settings.json
├─ psmux/
│   └─ psmux.conf
├─ claude/
│   └─ CLAUDE.md
├─ bash/                 ← Linux 専用
│   └─ .bashrc
│
├─ install.ps1 / install.sh   ← リポジトリ → PC へ配置する
└─ sync.ps1    / sync.sh      ← PC → リポジトリ へ取り込む
```

---

## 仕組み（コピー方式）

このリポジトリは **シンボリックリンクではなくコピー** で設定を配置する。
特別な権限が要らず、どのPCでも確実に動く代わりに、
**設定を編集したら `sync` で取り込む** というひと手間が必要。

```
   ┌────────────────────┐                   ┌────────────────────┐
   │  dotfiles リポジトリ │                   │   実際に使う場所     │
   │                    │  ── install ──▶   │                    │
   │  nvim/init.lua     │                   │ ~/.config/nvim/... │
   │  powershell/...    │  ◀──  sync  ──    │ Documents/...      │
   │  vscode/...        │                   │ %APPDATA%/Code/... │
   └────────────────────┘                   └────────────────────┘
            │                                          ▲
            │ git push / git pull                      │ ここを編集する
            ▼                                          │
        GitHub ────────────────── 他のPCへ ────────────┘
```

**日常の流れ:**

```
設定を編集  →  sync で取り込む  →  git commit → git push
                                                    │
他のPCで                                            ▼
git pull  →  install で配置  ←────────────────── GitHub
```

---

## 使い方

### 新しいPCをセットアップする

**Windows:**

```powershell
git clone https://github.com/capypara20/dotfiles.git "$HOME\dotfiles"
cd "$HOME\dotfiles"
.\install.ps1
```

やること:
1. `XDG_CONFIG_HOME` を `~\.config` に設定（未設定の場合のみ）
2. scoop が無ければインストール → バケット追加 → アプリを一括インストール
3. 設定ファイルを各アプリの場所へコピー

**Linux:**

```bash
git clone https://github.com/capypara20/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash install.sh
```

### 設定を変更したあと（リポジトリに取り込む）

```powershell
cd "$HOME\dotfiles"
.\sync.ps1          # PC 側の設定をリポジトリへコピー
git diff            # 何が変わったか確認
git add -A
git commit -m "nvim のキーマップを追加"
git push
```

Linux なら `bash sync.sh`。

### 他のPCで最新に追いつく

```powershell
cd "$HOME\dotfiles"
git pull
.\install.ps1 -SkipScoop    # 設定ファイルの配置だけやり直す
```

---

## オプション

| オプション | 意味 |
|---|---|
| `.\install.ps1 -DryRun` | 何が起きるか表示するだけ（実際には変更しない） |
| `.\install.ps1 -SkipScoop` | scoop 関連を飛ばして、設定ファイルのコピーだけ |
| `.\sync.ps1 -DryRun` | 同上（取り込みの予行演習） |
| `bash install.sh --dry-run` | Linux 版の予行演習 |

---

## このPCだけの設定を書きたいとき

全PCで共通にしたくない設定（会社PCのプロキシ、そのPCにしか無いパスなど）は、
**`profile.local.ps1`** に書く。`.gitignore` 済みなので Git には入らない。

- 置き場所: PowerShell プロファイルと同じフォルダ
  （例: `Documents\PowerShell\profile.local.ps1`）
- `profile.ps1` の最後で自動的に読み込まれる

---

## 注意点

- **上書き前のファイルは消していない。** `install` は既存ファイルを
  `settings.json.bak-20260810-153000` のような名前で同じ場所に残す。
- **`sync` はフォルダを一度消してからコピーする。** nvim のように
  フォルダごと扱うものは、PC 側で消したファイルがリポジトリからも消える。
  Git 管理下なので `git checkout` で戻せる。
- **scoop のアプリ一覧はバージョンを含めない。** 新しいPCでは常に最新版が入る。
  グローバルインストール（管理者権限が必要なもの）は一覧から除外している。
- **フォントは scoop で管理しない。** Nerd Font は手動でインストールする方針。
  Windows Terminal の設定には `RobotoMono Nerd Font` が入っているので、
  フォントを入れていないPCでは文字が □ になる。先にフォントを入れること。
- **Windows Terminal は開いたまま install すると設定が戻ることがある。**
  終了時に、起動中に保持していた内容で書き戻されるため。
  反映されないときは Windows Terminal を再起動する。
- **Claude Code は `CLAUDE.md` だけを管理している。**
  同じ `~/.claude/` にある `.credentials.json` は認証情報なので、
  スクリプトは意図的に触らない。GitHub にも上げてはいけない。
