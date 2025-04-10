# Groups Shelf

Groups Shelf is a [Glyphs](https://glyphsapp.com/) kerning group manager.  
<img src="./img/GroupsShelf.png" width="701" />

- Visualise and manage kerning groups 
- Rename groups while copying kerning values
- Automatically add missing composites

### Installation

1. [Install using the Glyphs Plugin Manager](https://pkolchanov.ru/redirects/groupsshelf.html). Or double-click the `GroupsShelf.glyphsPlugin` file to install the plugin manually. Glyphs will show a confirmation pop-up. 
2. Open the plugin panel using Window → Groups Shelf 

### Group View
Group View shows all glyphs of the kerning group.

- `-` and `+` buttons in the bottom will remove or add glyphs selected in the Edit View to the selected group.
- `Add missing composites` in the group menu will add composite glyphs if the parent glyph is presented in the group. For example, if `A` is in the group, `Á` will be added. 
- `Remove group` in the group menu will remove the selected goup and kerning pairs. 

<img src="./img/GroupMenu.png" width="600" />

### Rename Groups palette
The palette to rename all groups in the font. It's useful for removing or adding prefixes and suffixes, like `KO_` and `.1`. 
You can choose between substring or regular expression substitution. It's also updates related kerning pairs. 

<img src="./img/RenameGroups.png" width="230" />

### Fix Groups palette

- `Remove groups without kern pairs` literally deletes those groups. 
- `Add missing composites` will add composites for all groups.

<img src="./img/FixGroups.png" width="230" />

### Credits 
> This project is sponsored by [bolditalic.studio](https://bolditalic.studio/)

Pavel Kolchanov, Dmitry Goloub, 2025
