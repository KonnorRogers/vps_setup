NODE_VERSION="11.15.0"
main(){
  # If the user already has an $NVM_DIR set but nvm not installed, create .nvm
  if [[ ! -d "$NVM_DIR" ]]; then
    mkdir -p "$NVM_DIR"
  fi

  # Pull in NVM
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
  # Restart the shell
  source "../restart_shell.bash"
  nvm install "$NODE_VERSION"
  nvm use "$NODE_VERSION"
}
