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
bash -- <(curl -o- https://raw.githubusercontent.com/TsutomuNakamura/dotfiles/develop/install.sh) -b develop
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

# Recommended emulators
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
I introduce you applications and features that the dotfiles will bring.

## vim
### NERDTree
https://github.com/scrooloose/nerdtree
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

# For Mac users
I found that there are some differences between Mac and Linux for expressing fonts on terminal.
In Linux, you can experience the best view by fontconfig but Mac doesn't.
For the reasons mentioned above, I recommend to set font to NertFont on your Mac.

# Concept (and goal)
These dotfiles is made on the concept as simple and visibility but utilities satisfactory.
Customizing these files are now under ongoing and will commit new customizations for continuously.

# License
The code is available under the MIT license.

