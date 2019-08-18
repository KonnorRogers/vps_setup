#!/bin/bash

main(){
  # installs sops via go get -u 'sops'
  SOPS="\\n\\nNow installing SOPS. This may take a bit, please wait\\n"
  printf "$SOPS"
  if [[ -z "$GOPATH" ]]; then
    export GOPATH="$HOME/go"
    export PATH="$PATH:$GOPATH/bin"
  fi

  go get -u go.mozilla.org/sops/cmd/sops
}

main
