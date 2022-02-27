# Change shell to bash
chsh -s /bin/bash

# Install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install nvm bash-completion
touch "$HOME/.secrets"
ln -s "$PWD/.bash_profile" "$HOME/.bash_profile"
ln -s "$PWD/.gitconfig" "$HOME/.gitconfig"
source "$HOME/.bash_profile"