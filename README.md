# ME_dotfiles

複数のPC（プライベート / 会社支給）で共有する dotfiles。

## 方針

- **共通設定は1か所**にまとめる（`shared/`、OS固有は `linux/` `windows/`）。
  各マシンへはシンボリックリンクで配置する。
- **そのマシンだけの差分**は、各設定が読み込む
  **ローカル上書きファイル（git管理外）** に置く。
  - 会社支給PCのように **このリポジトリへ push できない（clone専用）環境**でも、
    ローカル上書きファイルはそのマシンに手で置くだけなので問題なく使える。
  - 秘密情報（メール・トークン・社内ホスト名など）も自然とリポジトリ外に保てる。
- 差分が無いマシンは共通設定だけで完結する（ローカル上書きは“あれば読む”opt-in）。

## ディレクトリ構成

```
dotfiles/
├─ install.sh / install.ps1   # shared と OS固有をリンクするインストーラ
├─ shared/                     # OS非依存の共通設定
│  ├─ nvim/                    # = ~/.config/nvim（Win: %LOCALAPPDATA%\nvim）
│  │  ├─ init.lua              # 末尾で require("local")（あれば）
│  │  └─ lua/
│  │     ├─ config/ plugins/   # 共通設定・プラグイン
│  │     ├─ local.lua          # ← マシン固有の上書き（git管理外, 任意）
│  │     └─ local.lua.example  # ↑ の雛形
│  ├─ tmux/tmux.conf           # = ~/.tmux.conf（末尾で ~/.tmux.local.conf を読む）
│  └─ git/
│     ├─ gitconfig             # = ~/.gitconfig（~/.config/git/local.gitconfig を include）
│     └─ local.gitconfig.example
├─ linux/                      # Linux固有（.bashrc 等。末尾で ~/.bashrc.local を読む）
└─ windows/                    # Windows固有（PowerShell profile 等）
```

## ローカル上書きファイル一覧

| 設定 | 共通の実体 | ローカル上書き（git管理外） |
|------|-----------|------------------------------|
| neovim | `shared/nvim/` | `~/.config/nvim/lua/local.lua` |
| tmux   | `shared/tmux/tmux.conf` | `~/.tmux.local.conf` |
| git    | `shared/git/gitconfig` | `~/.config/git/local.gitconfig` |
| bash   | `linux/.bashrc` | `~/.bashrc.local` |

## 使い方

### Linux
```bash
# 安定した場所に clone（symlink がここを指すので場所は固定で）
git clone <repo> ~/dotfiles && cd ~/dotfiles
bash install.sh

# 必要に応じてローカル上書きを作成（雛形をコピーして編集）
cp shared/nvim/lua/local.lua.example shared/nvim/lua/local.lua
cp shared/git/local.gitconfig.example ~/.config/git/local.gitconfig
nvim   # 初回起動で lazy.nvim が自動導入される
```

### Windows（開発者モード or 管理者の PowerShell）
```powershell
git clone <repo> $HOME\dotfiles; cd $HOME\dotfiles
.\install.ps1
copy shared\git\local.gitconfig.example $HOME\.config\git\local.gitconfig
```

## 設定を増やすには
1. 共通なら `shared/`、OS固有なら `linux/` `windows/` に実体を置く。
2. `install.sh` / `install.ps1` の「配置」に `link`(`Link`) を1行足す。
3. マシンで差が出る部分は、その設定が読み込む `*.local`（git管理外）に逃がす。

## 秘密情報の扱い
APIキー・トークン・社内ホスト名・SSH鍵などはリポジトリに入れない。
上記のローカル上書きファイル（git管理外）に置く。
