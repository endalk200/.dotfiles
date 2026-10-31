# Agent gateway

Claude Code, Codex, and OpenCode send model requests through
[CLIProxyAPI](https://github.com/router-for-me/CLIProxyAPI), which pools the
Claude and ChatGPT subscriptions signed in to it.
[Oh My CPA](https://github.com/WizisCool/oh-my-cpa) records usage, cache hits,
and the 5-hour and weekly quota of each account.

| Service | Address | Started by |
| --- | --- | --- |
| CLIProxyAPI | `http://127.0.0.1:8317` | `brew services` |
| Oh My CPA | `http://127.0.0.1:8080` | LaunchAgent `dev.endalk200.oh-my-cpa` |

Both listen on loopback only. Sign in to Oh My CPA with the management key
(`~/.local/share/agent-gateway/management-key`).

## What lives where

The repo holds templates and client configuration, never secrets.

| Path | Tracked | Contents |
| --- | --- | --- |
| `agent-gateway/*.template*` | Yes | Proxy config, Oh My CPA `.env`, and LaunchAgent templates |
| `.local/bin/agent-gateway` | Yes | Setup and maintenance script |
| `.claude/settings.json` | Yes | `ANTHROPIC_BASE_URL` and `apiKeyHelper` point Claude Code at the proxy |
| `.codex/config.toml` | Yes | `model_provider = "cliproxyapi"`; the key comes from `CLIPROXY_API_KEY` |
| `.config/opencode/opencode.json` | Yes | `cliproxy-claude` and `cliproxy-codex` providers read the key from a file |
| `~/.local/share/agent-gateway/` | No | Client key, management key, Oh My CPA master key |
| `~/.cli-proxy-api/` | No | Rendered proxy config, account logins, logs |
| `~/.local/share/oh-my-cpa/` | No | Oh My CPA binary, `.env`, and database |

Back up `~/.local/share/agent-gateway/`. Without `omc-master-key`, the Oh My CPA
database cannot be read.

The client key reaches each tool differently:

- Claude Code runs `agent-gateway key` through `apiKeyHelper`.
- OpenCode reads the key file with `{file:...}`.
- Codex reads `CLIPROXY_API_KEY`. `.zshrc` exports it for terminals, and the
  `dev.endalk200.agent-gateway-env` LaunchAgent sets it for GUI apps at login.
  Apps started before that agent ran, such as a running ChatGPT app or T3 Code,
  get `401` from the proxy until they are restarted.

## Set up a new machine

```sh
brew install cliproxyapi
cd ~/.dotfiles && stow --verbose --target="$HOME" .
agent-gateway setup
agent-gateway login claude --no-browser   # once per Claude account
agent-gateway login codex --no-browser    # once per ChatGPT account
agent-gateway install-omc
agent-gateway status
```

Open each login URL in a private browser window and sign in to the intended
account. `setup` fails if `~/Library/LaunchAgents` is not owned by you; fix it with
`sudo chown "$USER":staff ~/Library/LaunchAgents`.

To prefer one account, add a top-level `"priority": 10` to its login file in
`~/.cli-proxy-api/`. Higher values are used first.

## Upgrade

```sh
brew upgrade cliproxyapi && brew services restart cliproxyapi
agent-gateway install-omc            # latest Oh My CPA; keeps .env and data
```

## Turn the gateway off

Remove these lines, then stop the services:

- `env.ANTHROPIC_BASE_URL` and `apiKeyHelper` in `.claude/settings.json`
- `model_provider = "cliproxyapi"` in `.codex/config.toml`

```sh
brew services stop cliproxyapi
launchctl bootout "gui/$(id -u)/dev.endalk200.oh-my-cpa"
```

Claude Code and Codex then use their own sign-ins again.
