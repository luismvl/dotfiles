# Neovim (LazyVim) — 15-minute starter

You don't need to learn vim to start. Learn these ~10 things; everything else
you can discover by pressing `<Space>` (the leader key) and reading the popup
that appears (that's `which-key`).

## The core loop

| Key | What it does |
|---|---|
| `h` `j` `k` `l` | Move left / down / up / right |
| `i` | Enter **insert mode** (start typing) |
| `Esc` | Back to **normal mode** (navigate) |
| `:w` `Enter` | Save the file |
| `:q` `Enter` | Quit |
| `:wq` `Enter` | Save and quit |
| `u` | Undo |
| `Ctrl-r` | Redo |

Golden rule: **normal mode = navigate, insert mode = type.** Press `i` to
write, `Esc` when done.

## Editing essentials

| Key | What it does |
|---|---|
| `dd` | Delete current line |
| `yy` | Copy (yank) current line |
| `p` | Paste below |
| `x` | Delete character under cursor |
| `/word` `Enter` | Search for "word" (`n` next, `N` prev) |
| `w` / `b` | Jump word forward / back |
| `0` / `$` | Jump to line start / end |
| `gg` / `G` | Jump to top / bottom of file |
| `:e <file>` | Open another file |

## The Space leader (`<Space>` = your super key)

Every menu below appears as a popup as you type it — just read it.

| Sequence | What it does |
|---|---|
| `<Space> f f` | Find file (fuzzy) |
| `<Space> f r` | Find recently opened files |
| `<Space> s g` | Search text in project (grep) |
| `<Space> b b` | Switch buffers (open files) |
| `<Space> g g` | Git UI (lazygit inside nvim) |
| `<Space> x x` | Trouble: list errors/warnings |
| `<Space> c a` | Code actions / quick fixes |
| `<Space> <Space>` | Previous buffer |

## Split screens

| Sequence | What it does |
|---|---|
| `<Space> w /` | Split vertical |
| `<Space> w -` | Split horizontal |
| `Ctrl-h` `Ctrl-j` `Ctrl-k` `Ctrl-l` | Jump between splits (also crosses tmux panes) |

## LSP superpowers (automatic)

- Errors and warnings show as you type; `<Space> x x` lists them all.
- Autocomplete pops up as you type — `Tab` to accept.
- Hover with `<Space> k h` (or `K`) to see docs/signatures.
- `<Space> g g` shows git status/staging in a panel.

## If you get lost

- `Esc Esc` gets you back to normal mode from almost anywhere.
- `<Space>` always shows the menu of what's possible.
- `:Lazy` shows the plugin manager (update everything: `U`).
- `:help` when truly stuck.

## Mental model

- LazyVim is just vim + sensible defaults. Everything you learn transfers to
  plain vim, tmux's vi-mode, and any editor with a vim mode (VS Code, Cursor,
  Zed all have one).
- This config is intentionally "quiet": no tab bar, no splash screen, no fancy
  popups, simple status line — so the editor gets out of your way while you
  learn.