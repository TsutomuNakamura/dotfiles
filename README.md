# Tsutomu's dotfiles
This is a collection of dotfiles that I use on a arch linux as usual.
When you run the install script, you can make this customized environment onto arch, ubuntu, fedora and Mac OS X instantly.

# Install and setup
You can install and setup the environment by using a command like below.

```
curl -o- https://raw.githubusercontent.com/TsutomuNakamura/dotfiles/develop/install.sh | bash
```

It will install dependency packages if you have root privileges or belong to sudoers.
If you want not to install dependency packages, you can specify the option "-n" like below.

```
curl -o- https://raw.githubusercontent.com/TsutomuNakamura/dotfiles/develop/install.sh | bash -s -- -n
```

This script will clone this repository at ~/.dotfiles then create symbolic links to .vim .tmux etc in ~/.dotfiles.

# Tested distribution and OS
This dotfiles tested on the environment like below, but on arch the most suitable for because I usually use arch linux and use it.

| Distribution or OS |
| ------------------ |
| arch               |
| ubuntu             |
| debian             |
| fedora             |
| MacOS              |

# Concept (and goal)
This dotfiles is made on the concept as simple and visibility but utilities satisfactory.
Customizing these files are now under ongoing and will commit new customizations for continuously.

# License
The code is available under the MIT license.

