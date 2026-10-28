# Dotfiles

This repository contains my personal configuration files (dotfiles) for various tools and applications that I use on a daily basis. These dotfiles help in setting up a consistent and efficient development environment across different machines.

## Set up a new machine

Install your tools, then link the dotfiles into your home directory with Stow:

```sh
brew install stow
git clone https://github.com/endalk200/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow --verbose --target="$HOME" .
```

If Stow reports conflicts, move the existing conflicting configs to a backup location and rerun the command. Reload your tools afterward.

After pulling updates, run `stow --verbose --target="$HOME" .` from `~/.dotfiles` again to link new files.

## Tools Configured

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

`brew install zoxide`
