# Groups Shelf

**[English](#english) | [日本語](#日本語)**

---

> [!NOTE]
> This is a fork of the original [Groups Shelf](https://github.com/pkolchanov/GroupsShelf) by Pavel Kolchanov.  
> This fork adds **Japanese localization** and **Vertical Kerning support**.

---

<a name="english"></a>
## English

Groups Shelf is a [Glyphs](https://glyphsapp.com/) kerning group manager.  
<img src="./img/GroupsShelf.png" width="701" />

### Features
- Visualise and manage kerning groups 
- Rename groups while copying kerning values
- Automatically add missing composites
- **New (2026)**: Japanese localization and Vertical Kerning support

### Installation
1. Download the latest `GroupsShelf.glyphsPlugin`.
2. Double-click the file to install. Glyphs will show a confirmation pop-up. 
3. Open the plugin panel using **Window → Groups Shelf**.

### Usage

#### Group View
Group View shows all glyphs of the selected kerning group.
- **Direction**: Horizontal and Vertical modes can be toggled at the top of the window.
- **Edit Group**: Use `-` and `+` buttons at the bottom to remove or add selected glyphs to the group.
- **Context Menu**: Right-click (or click the three dots) to access:
    - `Add missing composites`: Adds composite glyphs (e.g., `Á` if `A` is in the group).
    - `Remove group`: Deletes the group and its related kerning pairs.

<img src="./img/GroupMenu.png" width="600" />

#### Rename Groups Palette
Rename all groups in the font. Useful for formatting prefixes/suffixes (e.g., `KO_` or `.sc`).  
- Supports substring and regular expression substitution.
- Automatically updates related kerning pairs.

<img src="./img/RenameGroups.png" width="230" />

#### Fix Groups Palette
- `Remove groups without kern pairs`: Cleans up unused groups.
- `Add missing composites`: Scans and adds composites for all groups in the font.

<img src="./img/FixGroups.png" width="230" />

---

<a name="日本語"></a>
## 日本語

Groups Shelf は、[Glyphs](https://glyphsapp.com/) 用のカーニンググループ管理プラグインです。

### 主な機能
- **カーニンググループの可視化と管理**: 直感的なインターフェースでグループと所属グリフを確認できます。
- **グループ名の一括変更**: カーニング値を保持したまま、プレフィックスやサフィックスの追加・置換が可能です（正規表現対応）。
- **自動的な複合字の追加**: ベースとなる文字がグループにある場合、アクセント付き文字などの複合字を自動で追加します。
- **縦カーニング対応**: 縦方向のカーニンググループ（Top/Bottom）およびペアの編集に対応しました。
- **UIの日本語化**: アプリの言語設定に合わせて日本語で表示されます。

### インストール
1. 最新の `GroupsShelf.glyphsPlugin` をダウンロードします。
2. ファイルをダブルクリックしてインストールします。Glyphs が確認ダイアログを表示します。
3. **ウィンドウ → Groups Shelf** メニューからパネルを開きます。

### 使い方

#### グループ表示 (Group View)
選択されたカーニンググループに含まれる全てのグリフを表示します。
- **方向の切り替え**: ウィンドウ上部のスイッチで「横（水平）」と「縦（垂直）」を切り替えられます。
- **グループの編集**: 下部の `-` および `+` ボタンを使用して、編集画面で選択中のグリフをグループから削除したり追加したりできます。
- **コンテキストメニュー**: 三点リーダー（または右クリック）から以下の機能が使えます：
    - `足りない複合字を追加`: 親グリフがグループにある場合、対応する複合字（例: `A` に対する `Á`）を自動追加します。
    - `グループを削除`: 選択中のグループと関連するカーニングペアを削除します。

#### グループ名の変更 (Rename Groups)
フォント内の全てのグループ名を一括で変更します。プレフィックス（`KO_` など）やサフィックスの管理に便利です。
- 文字列置換または正規表現による置換が可能です。
- 関連するカーニングペアも自動的に更新されます。

#### グループの修正 (Fix Groups)
- `カーニングペアのないグループを削除`: 使われていないグループを一括削除します。
- `足りない複合字を追加`: フォント内の全グループを対象に、不足している複合字をスキャンして追加します。

---

## Build Instructions (for Developers)
To build the plugin from source:

1. Clone the repository.
2. Run the following command in the project root:
   ```bash
   xcodebuild -scheme GroupsShelf -configuration Release CONFIGURATION_BUILD_DIR=./build CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED=YES INFOPLIST_KEY_NSPrincipalClass="GroupsShelf" INFOPLIST_KEY_CFBundleName="Groups Shelf"
   ```
3. Copy the built `GroupsShelf.glyphsPlugin` from the `build/` directory to the project root or your Glyphs Plugins folder.

---

### Credits 
> This project is originally sponsored by [bolditalic.studio](https://bolditalic.studio/)

Original Authors: Pavel Kolchanov, Dmitry Goloub  
Updated 2026: **Palf** (Japanese localization and Vertical Kerning support)
