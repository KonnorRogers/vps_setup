# frozen_string_literal: true

namespace 'config' do
  desc "copies dotfiles from a local dir to the config dir. 
By default, copies from ~ to vps_setup/config.
This can be changed by changing :local_dir and :config_dir
Use this task via:
    $ rake config:pull
default :local_dir to ~
default: :config_dir to ./vps_setup/config

with arguments:
    $ rake \"config:pull[local_dir, config_dir]\""
  # Allows the setting of a backup_dir for your dotfiles
  task :pull, [:local_dir, :config_dir] do |_t, args|
    # swapped positions of local_dir and config_dir to allow a nil config_dir
    tilde_to_home(args)
    args.with_defaults(config_dir: CONFIG_DIR, local_dir: Dir.home)

    VpsSetup::Pull.pull_all(config_dir: args.config_dir, local_dir: args.local_dir)
  end

  # used to see how rake args work
  task :example, [:example1, :example2] do |_t, args|
    puts args

    args_hash = tilde_to_home_hash(args)
    p args_hash
  end
end
