# frozen_string_literal: true

namespace 'config' do
  desc "copies dotfiles from a local dir to the config dir.
By default, copies from ~ to vps_setup/config.
This can be changed by changing :config_dir and :local_dir
Use this task via:
    $ rake config:pull
default :local_dir to ~
default: :config_dir to ./vps_setup/config

with arguments:
    $ rake \"config:pull[config_dir, local_dir]\"

Both arguments are optional and can be omitted
to test what will be pulled, use:

    $ rake \"config:pull[~/test_dir]\"

This will put all files to be pulled into the ~/test_dir from ./vps_setup/config
  "

  # Allows the setting of a backup_dir for your dotfiles
  task :pull, [:config_dir, :local_dir] do |_t, args|
    # swapped positions of local_dir and config_dir to allow a nil config_dir
    args.with_defaults(config_dir: VpsCli::CONFIG_DIR, local_dir: Dir.home)

    # converts args from a Rake::TaskArgument to a hash
    hash = tilde_to_home_hash(args)
    VpsCli::Pull.pull_all(cfg_dir: hash[:config_dir], local_dir: hash[:local_dir])
  end

  # used to see how rake args work
  task :example, [:example1, :example2] do |_t, args|
    puts args

    args_hash = tilde_to_home_hash(args)
    p args_hash
  end
end
