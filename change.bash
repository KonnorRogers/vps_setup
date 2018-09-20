#tmux
cp ~/.tmux.conf ~/.tmux.conf.orig
ln -f -s ~/vps-setup/tmux.conf ~/.tmux.conf
# vim
cp ~/.vimrc ~/.vimrc.orig
ln -f -s ~/vps-setup/vimrc ~/.vimrc
# zsh
cp ~/.zshrc ~/.zshrc.orig
ln -f -s ~/vps-setup/zshrc ~/.zshrc
# neovim
mkdir .config
mkdir nvim
cp ~/.config/nvim/init.vim ~/.config/nvim/init.vim.orig
ln -f -s ~/vps-setup/nvim/init.vim ~/.config/nvim/init.vim

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
