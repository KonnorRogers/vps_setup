# frozen_string_literal: true

require 'thor'

module VpsCli
  # The CLI component of this library
  # Integrates Thor
  # @see http://whatisthor.com/
  class Cli < Thor
    # this is available as a flag for all methods
    class_option :verbose, type: :boolean, aliases: :v, default: true
    class_option interactive: :boolean, aliases: :i, default: true
    class_options [:local_dir, :backup_dir, :local_sshd_config]

    desc 'copy_all', 'Copies files from <vps_cli/config_files>'
    def copy_all
      VpsCli::Copy.all(options)
    end

    desc 'pull_all', 'Pulls files into your vps_cli repo'
    options [:dotfiles_dir, :misc_files_dir]
    def pull_all
      VpsCli::Pull.all(options.dup)
    end
  end
end
