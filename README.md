# Offline Nvim
This repo contains an entirely offline Neovim configuration. Plugins have been cloned from the source, and their .git folders removed.

This is a fairly feature complete vim configuration, with proper code highlighting, language server integration, fuzzy searching, a file explorer.

## Repository Structure 
`pack/offline/start/` All the installed plugins

`lua/config/` Default neovim configuration and remap files

`init.lua` Configuration of the installed plugins

To install this configuration, it should be cloned into ~/.config/
The code in tmux configuration in ./pack/offline/start/tmux.nvim/.tmux.conf should be appended to your .tmux.conf to allow for seamless transition between tmux and vim panes. Panes can be moved between with ctrl + hjkl and resized with alt + hjkl.

## Installed plugins

- `telescope` - Fuzzy finder 
    - `plenary` - Dependency of Telescope and harpoon
- `nvim-tree` - File explorer (Better Netrw)
- `onedark` - Color Scheme
- `lualine` - Improved status bar: Shows current mode, open buffers, line number, filetype, etc
- `nvim-cmp` - Autocompletion
  - `cmp-path` - Enable path autocompletion
  - `cmp-nvim-lsp` - Links the language server to the autocompletion
- `nvim-lspconfig` - Implements language server features such as goto definition. Needs to connect to clangd.
- `Comment.nvim` - Adds shortcut to comment/uncomment code for many languages
- `harpoon` - Improved Vim Marks 
- `tmux.nvim` - Better tmux and vim integration - allow Ctrl + hjkl to switch between tmux and vim panes
- `nvim-treesitter` - Code highlighting + other features
- `undotree` - Open up a tree view similar to git log to view previous file states

## Notes
- At the moment, almost no lazy loading is being used. This can be implemented, however there is not a noticable startup delay when entering neovim.
- For the [tmux.nvim](https://github.com/aserowy/tmux.nvim) plugin to work correctly, some configuration needs to be added to .tmux.conf
- For everything to work properly, clangd needs to be isntalled for lsp features.
- Using Fzf as the backend for telescope would make it much faster.
- The treesitter plugin has been removed as neovim now integrates this by default. The .so compiled parsers need to be installed.

## Todo
- Treesitter parser installation
- Add Bear for compile_commands.json
- Snippets

## Demo Pictures
![Screenshot From 2025-02-26 23-43-28](https://github.com/user-attachments/assets/cea6febb-bc73-4af1-81f9-753f0d839199)
Goto definition and hover to show declaration / documentation
![Screenshot From 2025-02-26 23-44-53](https://github.com/user-attachments/assets/d5364166-0e71-4f93-bb69-ce18a34a3980)
Fuzzy file searching
![Screenshot From 2025-02-26 23-45-23](https://github.com/user-attachments/assets/4a347993-4bb2-4fb5-9fdb-1e8991b11c82)
Grep all files using telescope
![Screenshot From 2025-02-26 23-46-21](https://github.com/user-attachments/assets/c688ddf5-c643-4ce2-a292-640dbc5ceaaf)
Improved File explorer
![Screenshot From 2025-02-26 23-48-27](https://github.com/user-attachments/assets/c72df16c-366c-48a6-8455-411c0dc75538)
Undo tree (left). Error highlighting and warnings (requires clangd)


# Documentation

## File Explorer
The plugin nvim-tree provides a file explorer similar to the one found in common IDEs such as VSCode. It overrides and disables the default vim file explorer Netrw, so if you prefer the original one, it can be re-enabled by commenting out the nvim-tree config code in the init.lua config file.

**<leader>ov** (Open Viewer) Opens the file tree
 
## File Search (Telescope)
Telescope is a fuzzy finder, used to search for files and strings. Very useful for jumping around files and searching for strings in multiple files.

**<leader>of** (Open Files) Opens a window to search for files in the current and all subdirectories
**<leader>os** (Open String) Opens a window to search for strings in the files in the current and all subdirectories
**<leader>ow** (Open Word) Opens a window to search for the string currently under the cursor
**<leader>ob** (Open buffers) Search in the current open vim buffers
**<leader>or** (Open resume) Resume the last search
**<leader>oh** (Open help) Search nvim documentation and plugin documentation

## Autocomplete, Language Server Features
The below keybinds are related to language server features. Such as autocomplete, goto definition, variable renaming, etc.

**K** Displays a floating window, showing the definition of the symbol under the cursor.
**gd** (Goto Definition) Jump to the definition of the function under the cursor.
**rn** (Rename) Rename the current variable/function under the cursor. This will work across multiple files.


