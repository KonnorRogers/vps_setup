
BIN="$HOME/bin"
VPS_CLI="$PWD/lib/vps_cli.rb"

main(){
  check_if_root
  sudo apt install ruby
  mkdir -p "$BIN"
  symlink_vps_cli
  export PATH="$PATH:$BIN"
}

symlink_vps_cli(){
  ln -fs "$VPS_CLI" "$BIN/vps-cli"
}

check_if_root(){
  if [[ `id -u` == 0 ]]; then 
    echo "Do not run this as sudo / root. Rerun this script." 1>&2
    exit 1
  fi
}
