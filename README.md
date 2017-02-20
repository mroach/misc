# mroach's misc scripts

## `dotfiles`

Configuration files that mostly live in my homedir. Includes configuration for:

* GNU Privacy Guard
* Bash
* Git
* [grc](https://github.com/garabik/grc) - generic colouriser
* tmux
* zsh

## `shell_setups`

Whether I'm using **zsh** or **bash**, configuration for apps and services
remains the same, so they've been moved out into separate scripts.

There's configuraiton here for

* rbenv
* pyenv
* gpg
* homebrew
* pow
* ssh
* tmux
* config - generic config like my $EDITOR and $LESS pager

The **Homebrew** configuration relies on storing the GitHub API token in the
macOS keychain. To add your own, run this:

```
security add-generic-password -a "$USER" -s 'Homebrew GitHub Token' -w 'TOKEN GOES HERE'
```

## `scripts`

### `macos_postgresql_fix.sh`

If macOS doesn't shut down cleanly (e.g. kernel panic), it can leave the pid file behind for PostgreSQL which
will prevent it from starting up again when the system reboots. If that happens,
this script checks to make sure the pid file is referencing a process that doesn't exist,
PostgreSQL isn't running, then deletes the pid file and starts PostgreSQL.
