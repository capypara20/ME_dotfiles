# ME_dotfiles

仕事用PCとプライベートPCで設定を使い分けるための dotfiles。
**「OS軸」×「プロファイル軸(work / private)」** の2軸で管理する。

## 考え方

- **共通の土台**は1つだけ持つ（`shared/`）。
- 環境ごとの差分は、できるだけ**小さな入口ファイル**に閉じ込める。
- 「どの環境か」は **プロファイル**(`work` / `private`)で明示的に選ぶ。
  - OSが勝手に見る固定パスへ、リポジトリ内の実体を**シンボリックリンク**で配置する。

## ディレクトリ構成

```
dotfiles/
├─ install.sh / install.ps1   # プロファイルを決めてリンクを貼るインストーラ
├─ shared/                     # OS非依存・環境非依存の「共通の土台」
│  └─ nvim/                    # = ~/.config/nvim（Windowsは %LOCALAPPDATA%\nvim）
│     ├─ init.lua              # エントリポイント。末尾で require("profile")
│     └─ lua/
│        ├─ config/            # options / keymaps / lazy(プラグインマネージャ)
│        ├─ plugins/           # プラグイン定義（ファイルを足すだけで増やせる）
│        └─ profile.lua        # ← install時に生成。選択中プロファイルへのリンク（git管理外）
├─ profiles/                   # プロファイル固有の上書き
│  ├─ work/nvim/profile.lua    #   仕事用の差分
│  └─ private/nvim/profile.lua #   プライベート用の差分
├─ linux/                      # Linux固有（.bashrc など）
└─ windows/                    # Windows固有（PowerShell profile など）
```

## 使い方

### Linux

```bash
# プロファイルを環境変数で明示（おすすめ）
DOTFILES_PROFILE=work bash install.sh

# もしくは引数なしで実行 → 対話で work/private を聞かれる
bash install.sh
```

### Windows（開発者モード or 管理者の PowerShell）

```powershell
$env:DOTFILES_PROFILE = "work"; .\install.ps1
```

一度実行すると、選んだプロファイルが `~/.dotfiles-profile` に記録され、
次回以降は引数なしでも同じプロファイルが使われる。

## 設定を増やすには

1. リポジトリに実体を置く（共通なら `shared/`、OS固有なら `linux/` `windows/`）。
2. `install.sh` / `install.ps1` の「配置」セクションに `link` を1行足す。
3. 環境で差分が出るものは、`profiles/work/...` と `profiles/private/...` に
   それぞれ用意し、共通側からはその入口だけを読み込む（nvim の `profile.lua` が手本）。

## 秘密情報の扱い

APIキー・トークン・社内ホスト名・SSH鍵などは **リポジトリに入れない**。
`*.local` という名前のファイル（`.gitignore` 済み）に分離して、各マシンで手置きする。
