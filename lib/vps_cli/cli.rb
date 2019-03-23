# frozen_string_literal: true

require 'thor'

module VpsCli
  # The CLI component of this library
  # Integrates Thor
  # @see http://whatisthor.com/
  class Cli < Thor
    # # this is available as a flag for all methods
    # class_option :verbose, type: :boolean

    # desc 'Copies all files from <vps_cli/config_files> to <local_dir>'
    # options :local_dir, :backup_dir, :local_sshd_config
    # option interactive: :boolean, aliases: :i, default: true
    # def copy_all
    #   VpsCli::Copy.all(options)
    # end

  end
end
