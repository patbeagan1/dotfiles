# libbeagan

This is a collection of shell functions and scripts which are included in the hopes that they will be helpful.

## Getting started

If you just want to grab a couple of aliases, you can source the individual files in the `aliases` folder. You can grab them straight from github by doing something like `source <(curl localhost:8000/alias_ls.zsh)`, wherever the script resides on your network.

If you just want to use a single script, you can download it via the github raw url,
or run it in place with `curl xyz.sh | zsh`.
I make some effort to keep scripts `sh` compatible, but until someone requests that specifically, no guarantees.

## Using all of the available scripts

First, clone this project to your machine
`git clone https://github.com/patbeagan1/libbeagan`

All of the scripts can be used by running the following command from your terminal, as long as you are in a zsh shell.

```zsh
source ./install.zsh
```

I source the install command from my `~/.zshrc` file. Keeping aliases in here keeps it much cleaner!

Ascii art generated from [here](https://www.coolgenerator.com/ascii-text-generator), stick letter font