# frozen_string_literal: true

require 'thor'

module VpsCli
  # The CLI component of this library
  # Integrates Thor
  # @see http://whatisthor.com/
  class Cli < Thor
    # this is available as a flag for all methods
    class_option :verbose, type: :boolean, aliases: :v, default: true
    class_option :interactive, type: :boolean, aliases: :i, default: true
    class_option :all, type: :boolean, aliases: :a, default: false

    class_options %i[local_dir backup_dir local_sshd_config]

    desc 'copy [OPTIONS]', 'Copies files from <vps_cli/config_files>'
    def copy
      VpsCli::Copy.all(options.dup) if options[:all]
    end

    desc 'pull [OPTIONS]', 'Pulls files into your vps_cli repo'
    options %i[dotfiles_dir misc_files_dir]
    def pull
      puts options[:all]
      VpsCli::Pull.all(options.dup) if options[:all]
    end

    desc 'install [OPTIONS]', 'installs based on the flag provided'
    option :full, type: :boolean, aliases: :f, default: false
    option :access_file, aliases: :af
    def install
      msg = puts 'Only full install has been implemented'
      return msg unless options[:full]

      VpsCli.full_install(options.dup)

      return if VpsCli.errors.empty?

      VpsCli.errors.each { |error| puts error.message }
    end
  end
end
