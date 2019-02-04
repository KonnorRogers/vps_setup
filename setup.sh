BIN="$HOME/bin"
VPS_CLI="$PWD/lib/vps_cli.rb"

main(){
  sudo apt install ruby
  mkdir -p "$BIN"
  symlink_vps_cli
}

symlink_vps_cli(){
  ln -fs "$VPS_CLI" "$BIN/vps-cli"
}
