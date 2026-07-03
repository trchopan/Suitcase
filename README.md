# Quang Tran @trchopan

## Configuration files

## Setup brew and install applications before stow

### Install Homebrew

Check the Homebrew page for latest install script

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Install required core CLI tools (before stow)

These are used by shell aliases, scripts, and terminal workflow.

```bash
brew install zsh fish tree wget fd eza tmux htop ripgrep zoxide jq stow gh fzf git-delta
```

### Install required editor and sync tools (before stow)

These map directly to stow packages in this repository.

```bash
brew install neovim lazygit syncthing
```

### Install required desktop apps for tracked configs

These match the stow packages in this repository.

```bash
brew tap homebrew/cask-fonts
brew install --cask font-hack-nerd-font karabiner-elements alacritty ghostty hammerspoon vivaldi emacs
```

### Install required window manager tools

```bash
brew install koekeishiya/formulae/yabai koekeishiya/formulae/skhd
brew trust --formula felixkratz/formulae/borders
brew install borders
```

### Optional programming, container and cloud

```bash
brew install pyenv pyenv-virtualenv go deno awscli mise uv bun
brew install --cask docker google-cloud-sdk
```

### Optional programs for release blogs

```bash
brew install vips hugo
```
