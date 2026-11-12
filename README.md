# Dotfiles

My dotfiles, managed with [GNU Stow](https://www.gnu.org/software/stow/).

Repo: <https://github.com/f1gjam/dotfiles>
(`git@github.com:f1gjam/dotfiles.git`)

Each top-level folder is a stow **package**. Inside a package, the layout mirrors
`$HOME`. For example `git/.gitconfig` becomes the symlink `~/.gitconfig`, and
`starship/.config/starship.toml` becomes `~/.config/starship.toml`.

| Package     | Links to                                      |
|-------------|-----------------------------------------------|
| `alacritty` | `~/.alacritty.toml`                           |
| `bash`      | `~/.bashrc`, `~/.bash_profile`                |
| `claude`    | `~/.claude/CLAUDE.md`, `~/.claude/skills/` (`gdrive-sync`, `gdoc-markdown-compat`) |
| `ghostty`   | `~/.config/ghostty/config`                    |
| `git`       | `~/.gitconfig`, `~/.gitignore` (needs `.stow-local-ignore`, see notes) |
| `nano`      | `~/.nanorc`                                   |
| `osx`       | `~/.osx` (macOS defaults script, run manually)|
| `ssh`       | `~/.ssh/config`                               |
| `starship`  | `~/.config/starship.toml`                     |

> The repo must live at `~/dotfiles`. Stow creates relative links from the
> parent of the stow directory, so a different location links to the wrong place.

## Set up a new machine

1. Install Homebrew and Stow:

   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   brew install stow
   ```

2. Clone the repo into your home directory:

   ```bash
   git clone git@github.com:f1gjam/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

   On a new machine the SSH key may not be set up yet. Clone over HTTPS
   instead (needs a GitHub login or token if the repo is private):

   ```bash
   git clone https://github.com/f1gjam/dotfiles.git ~/dotfiles
   ```

   The existing clone uses the remote `git@github-personal:f1gjam/dotfiles.git`.
   `github-personal` is a host alias defined in `~/.ssh/config` (the `ssh`
   package), so it only works once that file and its key are in place. To
   switch a fresh clone to it afterwards:

   ```bash
   git remote set-url origin git@github-personal:f1gjam/dotfiles.git
   ```

   Use the personal or work GitHub account as appropriate for the machine.

3. Preview what Stow will do. Nothing is changed:

   ```bash
   stow -nv bash git nano osx alacritty starship ghostty
   ```

   - No output or only `LINK:` lines: safe to continue.
   - `WARNING! ... existing target is not owned by stow`: a real file already
     exists, such as a default `~/.bashrc`. Go to "Conflicts" below.

4. Stow for real:

   ```bash
   stow -v bash git nano osx alacritty starship ghostty
   ```

5. Optional packages. Preview each with `-nv` first:

   ```bash
   stow -nv claude && stow -v claude
   stow -nv ssh && stow -v ssh
   ```

6. Open a new shell, or run `source ~/.bashrc`.

## Conflicts (files already exist in `$HOME`)

On a fresh machine, files such as `~/.bashrc` or `~/.gitconfig` may already
exist. Stow refuses to overwrite them. There are two ways to handle it.

**Keep the repo version (usual choice on a new machine).** Move the old file
out of the way, then stow:

```bash
mv ~/.bashrc ~/.bashrc.bak
stow -v bash
```

**Keep the machine's version.** `--adopt` moves the existing file into the
repo, replacing the repo copy, and then links it. Review and revert
afterwards:

```bash
stow --adopt -v ssh
git diff          # review what was pulled in
git checkout .    # discard it and keep the repo version
```

`--adopt` overwrites the repo copy, so commit or stash your work first.

## Restow, update and remove

| Task                                      | Command                  |
|-------------------------------------------|--------------------------|
| Re-link after adding or renaming files    | `stow -R <package>`      |
| Remove a package's links                  | `stow -D <package>`      |
| Dry run of any command                    | add `-nv`                |
| Check for broken links in `$HOME`         | `find ~ -maxdepth 1 -xtype l` |

To pull changes from another machine:

```bash
cd ~/dotfiles
git pull
stow -R bash git nano osx alacritty starship ghostty   # only needed if files were added or moved
```

To add a new config, for example `tmux`:

```bash
mkdir -p ~/dotfiles/tmux
mv ~/.tmux.conf ~/dotfiles/tmux/.tmux.conf
cd ~/dotfiles && stow -v tmux
```

## Stow flags

- `-n`: dry run. Show what would happen and change nothing.
- `-v`: verbose. Print each action.
- `-R`: restow. Remove and re-create the links.
- `-D`: delete. Remove the links.
- `--adopt`: move existing target files into the package, then link them. It
  is the only option that modifies the repo.

## Notes

- Stow normally skips `.gitignore` files, so they are never linked into `$HOME`.
  The `git` package has its own `git/.stow-local-ignore`, which replaces
  Stow's default skip list with one that no longer skips `.gitignore`. Because
  of that, `git/.gitignore` is linked to `~/.gitignore` (your global ignore
  file). Without `.stow-local-ignore`, only `~/.gitconfig` would be linked.
  The file does not hide anything; it only changes what Stow skips.
- If `~/.claude` already exists, Stow links the files inside it one by one
  rather than replacing the folder. This is expected.
- Claude Code only finds skills at `~/.claude/skills/<name>/SKILL.md`. Put new
  skills in `claude/.claude/skills/<name>/` and run `stow -R claude`. Skills
  placed directly under `claude/.claude/` are not detected.
- `~/.claude/skills` is a single link to the repo folder, so any skill added
  there appears at once. Other tools that write into `~/.claude/skills`
  will write into the repo.
- `~/.claude/llm-budget` is a link to `~/.ai/skills/llm-budget`, made outside
  Stow, and is not in this repo.
- `settings.json` and `settings.local.json` are not tracked, because they differ
  per machine and company.
- `ssh` may need `--adopt` if `~/.ssh/config` already exists. Keep key files
  out of this repo.
