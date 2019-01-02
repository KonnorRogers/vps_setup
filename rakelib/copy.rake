# frozen_string_literal: true

BACKUP_DIR = File.join(Dir.home, 'backup_files')

namespace 'config' do
  desc "copies from a config dir to backup & dest dirs.
This can be accessed via:
    $ rake config:copy
default :backup_dir to ~/backup_config
default :local_dir to ~

or with arguments:
    $ rake \"config:copy[/path/to/backup_dir, /path/to/dest_dir]\""

  # Allows the setting of a backup_dir for your dotfiles
  task :copy, [:backup_dir, :dest_dir] do |_t, args|
    args.with_defaults(backup_dir: BACKUP_DIR, dest_dir: Dir.home)

    hash = tilde_to_home_hash(args)

    puts hash[:backup_dir]
    puts hash[:dest_dir]
    VpsSetup::Copy.copy(backup_dir: hash[:backup_dir], dest_dir: hash[:dest_dir])
  end
end
