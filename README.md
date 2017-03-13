# Tsutomu's dotfiles
This is a collection of dotfiles that I use on a arch linux as usual.
When you run the install script, you can make this customized environment onto arch, ubuntu, fedora and Mac OS X instantly.

# Install and setup
These install methods will clone this repository at ~/.dotfiles and create symbolic links to .vim .tmux etc in ~/.dotfiles.

## Standard method
```
curl -o- https://raw.githubusercontent.com/TsutomuNakamura/dotfiles/master/install.sh | bash
```
It will install dependency packages if you have root privileges or belong to sudoers.

## Without installing dependency packages
If you want not to install dependency packages, you can specify the option "-n" like below.
```
curl -o- https://raw.githubusercontent.com/TsutomuNakamura/dotfiles/master/install.sh | bash -s -- -n
```
## Clone with ssh protocol
Usually, the install script clone this repository by using https protocol but if you want to clone it by using ssh protocol, you can specify the option "-g" like below

```
curl -o- https://raw.githubusercontent.com/TsutomuNakamura/dotfiles/master/install.sh | bash -s -- -g
```

## Clone with specific branch or tag
This script can clone this specific branch or tag of repository for developers or the man who want to use other main versions of dotfiles.
```
curl -o- https://raw.githubusercontent.com/TsutomuNakamura/dotfiles/develop/install.sh | bash -s -- -b develop
```
This command will clone the develop branch of the repository.


+ Images
![Basic visual](https://github.com/TsutomuNakamura/dotfiles/wiki/img/dotfiles_policy01.png)

# Tested distribution and OS
These dotfiles tested on the environment like below, but on arch the most suitable for because I usually use arch linux and use them.

| Distribution or OS |
| ------------------ |
| arch               |
| ubuntu             |
| debian             |
| fedora             |
| MacOS              |

# Emulators recommended
These dotfiles uses a few many patched fonts.
Some patched fonts has lost shape on some terminal emulators.
Terminal that has been tested are like below.

| application        | OS    | Condition |
| ------------------ | ----- | --------- |
| Gnome terminal     | Linux | ◎        |
| Konsole            | Linux | ○        |
| Terminal (Mac)     | Mac   | ○        |
| iTerm (Mac)        | Mac   | ○        |

# Applications and feathres
I introduce you applications and features that I commonly used.

## vim
### NERDTree
Run vim and push "tr", then NERDTree will open.

### vim-airline
vim-airline will provide cool status line for vim!

## tmux
### tmuxline

![Lose shape](https://github.com/TsutomuNakamura/dotfiles/wiki/img/dotfiles_tmuxline00.png)
<br />
tmuxline has some useful icons.
Each icons gives us informations like below.

* basic

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

# Concept (and goal)
These dotfiles is made on the concept as simple and visibility but utilities satisfactory.
Customizing these files are now under ongoing and will commit new customizations for continuously.

# Bug
On some environment, these dotfiles may occur errors due to be specified "ambiwidth=double" and some font aliases in ~/.vim/myconf/ambiwidth.conf that is called from .vimrc.
For instance, errors which I have met are like below.

+ The error message appears when command vim executed.
```
E834: Conflicts with value of 'listchars': ambiwidth=double
```
+ Lose shape powerline of vim.
![Lose shape](https://github.com/TsutomuNakamura/dotfiles/wiki/img/lose_shape_powerline00.png)

If you want to eliminate the causes of defects, then you can disable the options by creating .vimrc_do_not_use_ambiwidth in your home directory.

```
touch ~/.vimrc_do_not_use_ambiwidth
```

# License
The code is available under the MIT license.

