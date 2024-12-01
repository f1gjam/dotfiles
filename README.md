#### My version of DOTFILES#####

Using Git STOW to manage these now


#### Download Dotfiles #####

Git clone the dotfiles directory to ~/ (as ~/dotfiles)


#### RUN STOW COMMANDS #####

cd ~/dotfiles

stow bash git nano osx alacritty starship


# Stow commands

``` 
stow –adopt -nv

-n: With this option we are telling stow not to execute any action, just tell us what it intends to do if we remove the option.
-v: This option is the one that will allow us to read what stow intends to do (in the end it’s to increase the verbosity level).
-adopt: This option is the only one that modifies the stow directory, all the others focus on the target directory. With this option what we do is that prior to stowear, it will move the current file in the target directory to the stow directory, and then create the link. Very useful when we are starting to create our .dotfiles.


```

# Double check the configs below
stow zellij??? 
stow ssh (may need --adopt)
