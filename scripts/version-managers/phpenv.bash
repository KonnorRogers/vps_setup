#!/bin/bash

PHP_VERSION="7.3.8"

main(){
  curl -L https://raw.githubusercontent.com/phpenv/phpenv-installer/master/bin/phpenv-installer \ | bash

  export PHPENV_ROOT="$HOME/.phpenv"
  if [ -d "${PHPENV_ROOT}" ]; then
    export PATH="${PHPENV_ROOT}/bin:${PATH}"
    eval "$(phpenv init -)"
  fi

  echo "$CWD"
  echo "$PWD"
  source "../restart_shell.bash"

  phpenv install --skip-existing "$PHP_VERSION"
  phpenv global "$PHP_VERSION"
}

main
