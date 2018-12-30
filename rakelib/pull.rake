# frozen_string_literal: true

BACKUP_DIR = File.join(Dir.home, 'backup_files')
CONFIG_DIR = File.join(File.expand_path('../', __dir__), 'config')

namespace 'config' do
  desc 'copies dotfiles from a local dir to the config dir.
  By default, copies from ~ to vps_setup/config.
  This can be changed by changing local_dir and config_dir'
  # Allows the setting of a backup_dir for your dotfiles
  task :copy, [:backup_dir, :dest_dir] do |_t, args|
    args.with_defaults(backup_dir: BACKUP_DIR, dest_dir: Dir.home)

    CopyConfig.copy(backup_dir: args.backup_dir, dest_dir: args.dest_dir)
  end
end
