# frozen_string_literal: true

require 'thor'

module VpsCli
  # The CLI component of this library
  # Integrates Thor
  # @see http://whatisthor.com/
  class Cli < Thor
    # this is available as a flag for all methods
    class_option :verbose, type: :boolean, aliases: :v, default: false
    class_option :interactive, type: :boolean, aliases: :i, default: false
    class_option :all, type: :boolean, aliases: :a, default: false

    class_options %i[local_dir backup_dir local_sshd_config]

    desc 'copy [OPTIONS]', 'Copies files from <vps_cli/config_files>'
    def copy
      Copy.all(options.dup) if options[:all]
    end

    desc 'pull [OPTIONS]', 'Pulls files into your vps_cli repo'
    options %i[dotfiles_dir misc_files_dir]
    def pull
      puts options[:all]
      Pull.all(options.dup) if options[:all]
    end

    desc 'install [OPTIONS]', 'installs based on the flag provided'
    def install
      msg = puts 'Only VpsCli::Install#all_install has been implemented'
      return msg unless options[:all]

      Install.all_install

      return if VpsCli.errors.empty?

      VpsCli.errors.each { |error| puts error.message }
    end

    desc 'push [OPTIONS]', 'pushes your ssh key to github'
    option :api_token
    option :ssh_file, aliases: :f
    option :title, aliases: :t
    option :uri, aliases: :u
    option :yaml_file, aliases: :y
    def push
      Access.post_github_ssh_key(options.dup)
    end
  end
end
