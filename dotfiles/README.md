# Manejar .dotfiles con git bare

## Crear git bare repository

### Estando en ~
```bash
git init --bare $HOME/dotfiles 
```

### Anadir alias a .bashrc o .zshrc
```bash
echo "alias dotfiles='/usr/bin/git --git-dir=$HOME/dotfiles --work-tree=$HOME'" >> $HOME/.bashrc
echo "alias dotfiles='/usr/bin/git --git-dir=$HOME/dotfiles --work-tree=$HOME'" >> $HOME/.zshrc
```

### 
```bash
dotfiles config --local status.showUntrackedFiles no
```


### Anadir 
```bash
dotfiles add /file
dotfiles commit -m "added file "


dotfiles checkout
```