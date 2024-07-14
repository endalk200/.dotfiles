# Dotfiles

This repository contains my personal configuration files (dotfiles) for various tools and applications that I use on a daily basis. These dotfiles help in setting up a consistent and efficient development environment across different machines.

## Tools Configured

- Alacritty
- Neovim
- Zsh
- Starship
- Tmux
- iTerm2
- Lazygit

## Directory structure

```
.
├── .config
│   ├── alacritty
│   │   ├── alacritty.toml
│   │   ├── catppuccin-frappe.toml
│   │   ├── catppuccin-macchiato.toml
│   │   ├── catppuccin-mocha.toml
│   │   └── one_dark.toml
│   ├── lazygit
│   │   └── config.yml
│   ├── nvim
│   │   ├── init.lua
│   │   ├── lazy-lock.json
│   │   └── lua
│   │       └── endalk200
│   │           ├── core
│   │           │   ├── init.lua
│   │           │   ├── keymaps.lua
│   │           │   └── options.lua
│   │           ├── lazy.lua
│   │           └── plugins
│   │               ├── alpha.lua
│   │               ├── autopairs.lua
│   │               ├── bufferline.lua
│   │               ├── colorscheme.lua
│   │               ├── comment.lua
│   │               ├── disabled.lua
│   │               ├── dressing.lua
│   │               ├── formatting.lua
│   │               ├── gitsigns.lua
│   │               ├── harpoon.lua
│   │               ├── indent-blankline.lua
│   │               ├── init.lua
│   │               ├── lazygit.lua
│   │               ├── linting.lua
│   │               ├── lsp
│   │               │   ├── lspconfig.lua
│   │               │   └── mason.lua
│   │               ├── lualine.lua
│   │               ├── nvim-cmp.lua
│   │               ├── nvim-tree.lua
│   │               ├── substitute.lua
│   │               ├── surround.lua
│   │               ├── telescope.lua
│   │               ├── todo-comments.lua
│   │               ├── treesitter.lua
│   │               ├── trouble.lua
│   │               ├── vim-maximizer.lua
│   │               └── which-key.lua
│   └── starship.toml
├── .p10k.zsh
├── .stow-local-ignore
├── .tmux.conf
├── .zshrc
├── README.md
├── iterm-config.json
├── rip.sh
└── tmux-sessions.sh
```

`brew install stow`

`brew install lazygit`

`brew install neovim`

`brew install --cask alacritty`

`brew install zoxide`
