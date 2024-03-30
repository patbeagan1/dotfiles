# libbeagan dotfiles

This is a collection of shell functions and scripts which are included in the hopes that they will be helpful.

To use this system, you must be running ZSH!

## 🛑 But first, a disclaimer 🛑

Sourcing 3rd party files (as in, the zsh `source` command) is pretty dang dangerous, even though it can be convenient. It works as if you were typing the commands yourself, using your current environment and user permissions. That means it has the ability to access your environment keys, and make any system changes you're allowed to. It's a good idea to make sure that you know what every line in a file does before proceeding.

You could just trust me 👀 but as someone who cares about your digital wellbeing in situations like this, I would recommend _not_ taking my word for it. It's better to read through and try just a couple of aliases at a time.  

# Getting Started

## Using all of the available scripts and aliases

_Per the disclaimer, only do this if you are me, or you are full of blind faith_

First, clone this project to your machine
`git clone git@github.com:patbeagan1/dotfiles.git`

Then, add the following to your `~/.zshrc` file

```sh
export LIBBEAGAN_HOME="$HOME/dotfiles"
source ~/dotfiles/install.zsh
```

## Using just one script

If you just want to use a single script, you can download it via the github raw url,
or run it in place like this

```sh 
sh <(curl --silent https://raw.githubusercontent.com/patbeagan1/dotfiles/master/scripts/math/sum.sh) 1,3,5 
# 9, which is 1+3+5
```

I make some effort to keep scripts `sh` compatible, but until someone requests that specifically, no guarantees.

## Using just one set of aliases

The aliases are kept in a bunch of alias files, loosely grouped by usage. If you want to use just one set of aliases, you can do so by sourcing the individual files in the `aliases` folder.

You can grab them straight from github by doing something like 

```sh
source <(curl https://raw.githubusercontent.com/patbeagan1/dotfiles/master/aliases/alias_git.zsh)`
# now `gs` stands for `git status`
```

---

Ascii art generated from [here](https://www.coolgenerator.com/ascii-text-generator), stick letter font
