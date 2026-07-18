# ME_dotfiles
いろいろな設定ファイルを管理するよ

# What management me dotfile??
## ターミナル設定
- windows > ターミナル
    - フォント
    - profile
    - windowsターミナルの設定
    - パッケージマネージャ(scoop)
- bash > linux
    - フォント
    - .profile

## アプリ
- windows
    - nvim
    - vscode
    - psmux
    - git
- linux
    - nvim
    - tmux
    - git

## ツール
- claudeCode
- githubCopilot

# DirectoryStructure
```
dotfiles/
├─ install.sh / install.ps1   # shared と OS固有をリンクするインストーラ
│                              # (Win: scoop導入→アプリ一括install→リンク配置)
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
   └─ scoop-apps.json          # scoopで入れるアプリ一覧（install.ps1が読む）
```