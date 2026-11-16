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

## AI coding agents

Claude Code (`.claude/settings.json`), Codex (`.codex/config.toml`), and OpenCode (`.config/opencode/`) configs are tracked here. They route model requests through a local proxy; see [agent-gateway/README.md](agent-gateway/README.md) to set it up. The `agent-gateway` folder is not linked into your home directory.

## Agent skills

[endalk200/skills](https://github.com/endalk200/skills) is the source of truth for agent skills. This repository installs the subset listed in `skills-lock.json`, and the skill files are committed, so a fresh clone needs only Stow:

- `.agents/skills/<name>/` holds each skill. Stow links `~/.agents` to this folder, so Codex, OpenCode, and other agents that read `~/.agents/skills` see every skill.
- `.claude/skills/<name>` links to that folder for Claude Code. Stow links each one into `~/.claude/skills`.

After pushing changes to the skills repository, update the installed copies and commit them:

```sh
skills-sync
git add skills-lock.json .agents/skills .claude/skills
git commit -m "chore(skills): sync from endalk200/skills"
```

`skills-sync` removes listed skills that the source no longer ships, updates the rest to the source's latest commit, deletes dead links from `~/.claude/skills`, and restows.

To change which skills are installed, run one of these from `~/.dotfiles`, then run `skills-sync`:

```sh
npx skills add endalk200/skills --skill <name> -a claude-code -a codex -y
npx skills remove <name> -y
```

Name both agents when adding. With only `claude-code`, the CLI copies the skill into `.claude/skills` instead of linking it, and the other agents never see it. Run `npx skills` without `-g`: `~/.agents` is this repository's folder, so a global install writes here under a separate lock file and leaves links that Stow does not own.

`.agents/skills/rex` comes from `rex skill setup`, not the skills repository.

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
