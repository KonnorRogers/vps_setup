# frozen_string_literal: true

BACKUP_DIR = File.join(Dir.home, 'backup_files')
CONFIG_DIR = File.join(File.expand_path('../', __dir__), 'config')

namespace :config do
  desc 'copies files from config dir to a destination dir, will place existing dotfiles into a backupdir'
  # Allows the setting of a backup_dir for your dotfiles
  task :copy, [:backup_dir, :dest_dir] do |_t, args|
    args.with_defaults(backup_dir: BACKUP_DIR, dest_dir: Dir.home)

    CopyConfig.copy(backup_dir: args.backup_dir, dest_dir: args.dest_dir)
  end

  task :example do
    p BACKUP_DIR
    p CONFIG_DIR
  end
end
