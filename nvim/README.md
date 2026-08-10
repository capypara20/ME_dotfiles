# 💤 LazyVim

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.

## 設定の構成（2026-08-10 整理）

```
~/.config/nvim/
├── templates/
│   └── plugin.lua              プラグイン追加用テンプレート（lazy.nvim は読まない）
└── lua/
    ├── config/
    │   ├── lazy.lua            ← サブフォルダの import はここに書く
    │   ├── options.lua
    │   ├── keymaps.lua
    │   └── autocmds.lua
    └── plugins/
        ├── lsp/                LSP・言語サーバ
        │   ├── 10_lspsaga.lua
        │   └── 20_powershell.lua
        ├── editor/             補完・編集操作
        │   ├── 10_blink.lua
        │   ├── 20_editing.lua
        │   └── 30_operator-replace.lua
        ├── ui/                 見た目・ステータスライン
        │   ├── 10_lualine.lua
        │   └── 20_snacks.lua
        └── tools/              ファイラー・その他ツール
            ├── 10_filer.lua
            ├── 20_hex.lua
            ├── 30_peek.lua
            └── 40_ddx.lua
```

### ルール

- ファイル名の先頭2桁は **10 刻み**。あとから間に割り込ませられるようにするため。
  - lazy.nvim はモジュール名の**アルファベット順**にファイルを読む（`lazy/core/plugin.lua` の `table.sort`）。
  - ただし決まるのは「spec を読む順番」だけで、**プラグインが起動する順番ではない**（それは `dependencies` / `event` から lazy.nvim が決める）。番号は主に人間向けの整理。
- 新しいプラグインを追加するときは `templates/plugin.lua` をコピーする。
- **サブフォルダを新設したら `lua/config/lazy.lua` の `spec` に `{ import = "plugins.<フォルダ名>" }` を1行追加する。**
  - lazy.nvim はサブフォルダを自動では読まない（`init.lua` がある場合を除く）。
- `lua/plugins/` 直下に `.lua` を置いても読み込まれない。必ずどれかのサブフォルダに入れること。
- `lua/plugins/` 配下の `.lua` は **必ずテーブルを return する**。空ファイルや return なしは
  `Invalid spec module: Expected a 'table' of specs` で起動エラーになる。

## 仕組み：設定はどう合体するのか

### 大原則

**lazy.nvim はファイル名もフォルダも見ていない。見ているのは GitHub のリポジトリ名だけ。**
名前が同じ spec は、どのファイルに書かれていても**上書きではなく合体（マージ）**される。

```
 LazyVim の spec                        自分の spec
 lazyvim/plugins/colorscheme.lua        lua/plugins/ui/30_catppuccin.lua
 ┌───────────────────────────┐          ┌───────────────────────────┐
 │ { "catppuccin/nvim",      │          │ { "catppuccin/nvim",      │
 │   lazy = true,            │          │   opts = {                │
 │   opts = {                │          │     transparent_background│
 │     integrations = {...}  │          │       = false,            │
 │   } }                     │          │   } }                     │
 └───────────┬───────────────┘          └───────────┬───────────────┘
             │       名前が同じ "catppuccin/nvim"    │
             └───────────────┬───────────────────────┘
                             ▼
              lazy = true / integrations / transparent_background
              が全部入った1つの spec になり
              require("catppuccin").setup(合体後のopts) が呼ばれる
```

→ LazyVim 側の設定は消えない。**好きな部分だけ足せばよい。**

### spec 1つの読み方

```lua
return {                    -- ファイルは必ず「リスト」を返す
  {
    "作者/リポジトリ名",     -- 【誰に】GitHub の名前。これが合体のキー
    opts = { ... },         -- 【何を】require("...").setup(opts) が自動で呼ばれる
    keys = { ... },         -- 【いつ】このキーを押したら読み込む
    event = "VeryLazy",     -- 【いつ】このタイミングで読み込む
    config = function() end,-- opts で足りないときだけ使う
  },
  { "別の作者/別のリポジトリ", opts = {} },  -- 1ファイルに何個でも書ける
}
```

### LazyVim 自体もプラグインである

LazyVim の設定（使うカラースキーム等）を変えたいときは、
`"LazyVim/LazyVim"` 宛ての spec に `opts` を書く。

```lua
-- LazyVim/lua/lazyvim/plugins/init.lua:16 で opts = {} が空のまま待っている
{ "LazyVim/LazyVim", priority = 10000, lazy = false, opts = {}, ... }

-- → LazyVim/lua/lazyvim/init.lua:6      M.setup(opts)
-- → LazyVim/lua/lazyvim/config/init.lua:176
--    options = vim.tbl_deep_extend("force", defaults, opts or {})
```

```lua
-- なので「色を変える」はこう書く
{ "LazyVim/LazyVim", opts = { colorscheme = "catppuccin-macchiato" } }
```

`"catppuccin/nvim"` 側に書いても色は変わらない。
catppuccin は色を**持っている**プラグイン、LazyVim は**どれを使うか決める**プラグイン。

### lua/config/ の役割分担

| ファイル | 中身 |
|---|---|
| `lazy.lua` | lazy.nvim の起動と、spec の集め方（import）の指定 |
| `options.lua` | Neovim 本体の設定（`vim.opt.*`）。プラグインとは無関係 |
| `keymaps.lua` | Neovim 本体のキーマップ。プラグインとは無関係 |
| `autocmds.lua` | Neovim 本体の自動実行。プラグインとは無関係 |

## カラースキーム

- 現在: `catppuccin-macchiato`（`lua/plugins/ui/30_catppuccin.lua`）
- **`<Space>u C`** でライブプレビュー付きの一覧が出る。カーソルを動かすだけで即反映。
  - ただし Enter で確定しても再起動すると戻る。恒久化はファイルの1行を書き換える。
- 選べる値: `catppuccin-latte` / `catppuccin-frappe` / `catppuccin-macchiato` / `catppuccin-mocha`

### 既知の警告

- 起動時の `[denops] 'C:\Users\capypara20\.deno\bin\deno' is not executable`
  - `lua/plugins/tools/40_ddx.lua` が指す Deno が未インストール。
  - Deno を入れるか、ddx / peek を使わないなら該当ファイルを消す。
