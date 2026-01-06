# My Dotfiles and Installer

To keep things in sync across any device I might be logged into, I came up with
this method inspired by
[Brandon Ivergo](https://brandon.invergo.net/news/2012-05-26-using-gnu-stow-to-manage-your-dotfiles.html)
to makange my dotfiles.

Each folder represents a "package" for a thing I want to sync. Imagine
everything in the `kitty` folder getting symlinked to
$HOME. If ```kitty``` contains a ```.config``` folder, the contents of **.config** will appear inside your ```/home/$USER/.config```
folder.

The dotfiles configuration then resides in a folder named after the package in
.config, it looks a little goofy but keeps things neat on the machine in the
end.

## Example

```markdown
.dotfiles ├── kitty │ └── .config │ └── kitty │ └── kitty.conf ├── nvim │ └──
.config │ └── nvim │ └── init.lua
```

## Installation

Run the install.sh script and follow the prompts. If you don't have a package
installed it will try to download it for you.

install.sh can be ran in -b (basic) mode or -f (full) mode. -f could just be
called kitty mode as that is all the extra stuff that gets installed. Don't need
kitty on something you'll only ssh into.

## Uninstallation

Run the uninstall.sh script and follow the prompts.
