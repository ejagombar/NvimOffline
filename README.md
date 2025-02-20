# Offline Nvim
This repo contains an entirely offline Neovim configuration. Plugins have been cloned from the source, and their .git folders removed.

This is a fairly feature complete vim configuration, with proper code highlighting, language server integration, fuzzy searching, a file explorer.

## Repository Structure 
`pack/offline/start/` All the installed plugins

`lua/config/` Default neovim configuration and remap files

`init.lua` Configuration of the installed plugins

To install this configuration, it should be cloned into ~/.config/

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
- Treesitter has the capability to download parsers using either curl or git. This has been disabled in the config.
- For the [tmux.nvim](https://github.com/aserowy/tmux.nvim) plugin to work correctly, some configuration needs to be added to .tmux.conf
- For everything to work properly, clangd needs to be isntalled for lsp features.
- Using Fzf as the backend for telescope would make it much faster.

## Todo
- Better documentation, more info about plugins, default keymaps 
- Remove uneccesary files from local plugin repositories
- Treesitter parser installation
- Add fzf
