# Tsutomu's dotfiles
This is a collection of dotfiles that I use on a arch linux as usual.
When you run the install script, you can make this customized environment onto arch, ubuntu, fedora and Mac OS X instantly.

# Install and setup
These install methods will clone this repository at ~/.dotfiles and create symbolic links to .vim .tmux etc in ~/.dotfiles.

## Standard method
```
bash <(curl -o- https://raw.githubusercontent.com/TsutomuNakamura/dotfiles/master/install.sh)
```
It will install dependency packages if you have root privileges or belong to sudoers.

## Without installing dependency packages
If you want not to install dependency packages, you can specify the option "-n" like below.
```
bash -- <(curl -o- https://raw.githubusercontent.com/TsutomuNakamura/dotfiles/master/install.sh) -n
```
## Clone with ssh protocol
Usually, the install script clone this repository by using https protocol but if you want to clone it by using ssh protocol, you can specify the option "-g" like below

```
bash -- <(curl -o- https://raw.githubusercontent.com/TsutomuNakamura/dotfiles/master/install.sh) -g
```

## Clone with specific branch or tag
This script can clone this specific branch or tag of repository for developers or the man who want to use other main versions of dotfiles.
```
branch="develop"
bash -- <(curl -o- https://raw.githubusercontent.com/TsutomuNakamura/dotfiles/${branch}/install.sh) -b ${branch}
```
This command will clone the develop branch of the repository.

+ Images
![Basic visual](https://github.com/TsutomuNakamura/dotfiles/wiki/img/dotfiles_policy01.png)

## Tested distribution and OS
This dotfiles tested on distribution and OS like below.

| Distribution or OS | Condition |
| ------------------ | --------- |
| Arch               |✔️         |
| Ubuntu             |✔️         |
| Fedora             |✔️         |
| MacOS              |✔️         |
| Debian             |✔️         |
| CentOS             |✔️         |

## Recommended terminal emulators
This dotfiles tested on some emulators like below.

| application        | OS    | Condition |
| ------------------ | ----- | --------- |
| Gnome terminal     | Linux | ✔️        |
| Konsole            | Linux | ✔️        |
| Terminal (Mac)     | Mac   | ✔️        |
| iTerm (Mac)        | Mac   | ✔️        |

# Applications and feathres
This dotfiles equipments some useful features.

## vim
### [NERDTree](https://github.com/scrooloose/nerdtree)
Run vim and press "tr", then NERDTree will open.

### [vim-airline](https://github.com/vim-airline/vim-airline) and [vim-airline-themes](https://github.com/vim-airline/vim-airline-themes)
vim-airline and vim-airline-themes provide cool status line for vim!

### [tmux](https://github.com/tmux/tmux)
Terminal multiplexer tmux makes you easy to control multi terminal.

### [tmuxline](https://github.com/edkolev/tmuxline.vim)
![Lose shape](https://github.com/TsutomuNakamura/dotfiles/wiki/img/dotfiles_tmuxline00.png)

tmuxline makes your tmux interface cool and icons provides you useful informations.

| icon        | description |
| ------------------ | ----- |
| ![Lose shape](https://github.com/TsutomuNakamura/dotfiles/wiki/img/dotfiles_tmuxline_icon00.png) | Hostname |
| ![Lose shape](https://github.com/TsutomuNakamura/dotfiles/wiki/img/dotfiles_tmuxline_icon01.png) | User name |
| ![Lose shape](https://github.com/TsutomuNakamura/dotfiles/wiki/img/dotfiles_tmuxline_icon02.png) | Load average |
| ![Lose shape](https://github.com/TsutomuNakamura/dotfiles/wiki/img/dotfiles_tmuxline_icon03.png) | Git branch name |
| ![Lose shape](https://github.com/TsutomuNakamura/dotfiles/wiki/img/dotfiles_tmuxline_icon04.png) | Index moditifed |
| ![Lose shape](https://github.com/TsutomuNakamura/dotfiles/wiki/img/dotfiles_tmuxline_icon05.png) | Updated files |
| ![Lose shape](https://github.com/TsutomuNakamura/dotfiles/wiki/img/dotfiles_tmuxline_icon06.png) | Deleted files |
| ![Lose shape](https://github.com/TsutomuNakamura/dotfiles/wiki/img/dotfiles_tmuxline_icon07.png) | Merge conflict |
| ![Lose shape](https://github.com/TsutomuNakamura/dotfiles/wiki/img/dotfiles_tmuxline_icon08.png) | Untracked files |
| ![Lose shape](https://github.com/TsutomuNakamura/dotfiles/wiki/img/dotfiles_tmuxline_icon09.png) | Ignored files |

# Local test
For developers, the install script in this repository could test with on docker container. Run the commands like below then the test cases will be started.
```
# docker build -t tsutomu/ubuntu-dotfiles --file ./test/container/ubuntu/Dockerfile .
# docker run --rm --volume ${PWD}:/home/foo/dotfiles -ti tsutomu/ubuntu-dotfiles su - foo -c "cd /home/foo/dotfiles && make test"
```

# Frequently asked
## Q. Will my dotfiles I'm using now has broken when installing this dotfiles?
Yes, this dotfiles will break your dotfiles using now.
But don't worry about it because your dotfiles will be backupd into the directory `~/.backup_of_dotfiles`.
Restore your dotfiles as needed, please.

## Q. Icons on vim and tmux are broken on my environment.
This dotfiles requires [nerd-font](https://github.com/ryanoasis/nerd-fonts). Your font-config will set your font-config on Linux such as Arch, Ubuntu, Fedora automatically but Mac won't.
Please set your font as needed by your hand.

# Concept (and goal) of this dotfiles
This dotfiles is developed on the concept as simple and visibility but utilities satisfactory.
It is now under ongoing and will commit new customizations and ideas for continuously.

# License
The code is available under the MIT license.

