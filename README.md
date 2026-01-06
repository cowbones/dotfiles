# My Dotfiles and Installer

To keep things in sync across any device I might be logged into, I came up with
this method inspired by
[Brandon Ivergo](https://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html)
to makange my dotfiles. This method ke

Clone this repo to something like `~/.dotfiles` then...

```bash
cd ~/.dotfiles
stow nvim
stow fish
stow whatever
```

Each folder represents a "package" for a thing I want to sync. You can use stow
nicely symlink `package/.config/package` to `/home/$USER/.config/package`. It
looks a little goofy but keeps things neat in the end. And combine that with a
git repo to keep a portable and version controlled set of dotfiles!

If you add a new package in this manner and want to use the installer.sh script,
theres a section you need to update in there.

## Example

```bash
.dotfiles
├── fish
│   └── .config
│       └── fish
│           └── main.fish
├── new_package
│   └── .config
│       └── new_package
│           └── .new_packagerc
```

## Installation

Run the install.sh script and follow the prompts. If you don't have a package
installed it will try to download it for you.

install.sh can be ran in -b (basic) mode or -f (full) mode. -f could just be
called kitty mode as that is all the extra stuff that gets installed. Don't need
kitty on something you'll only ssh into.

## Uninstallation

Run the uninstall.sh script and follow the prompts.
