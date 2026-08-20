# tomlinks

backup restoration software oriented for package-based dotfiles

run `odin build`
then run `./tomlinks restore ./test`

it will read tomlinks.ini and restore files. Usually it should do like 
```
./backup/configfile.txt = ~/.config/configfile.txt
```

but this one is for demo so it's simplified and it wont do things outside of working directory.
