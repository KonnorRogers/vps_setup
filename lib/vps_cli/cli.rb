# frozen_string_literal: true

require 'thor'
require 'open3'

module VpsCli
  # The CLI component of this library
  # Integrates Thor
  # @see http://whatisthor.com/
  class Cli < Thor
    PROJECT_DIR = File.expand_path('../..', __dir__)
    # this is available as a flag for all methods
    class_option :verbose, type: :boolean, aliases: :v, default: false
    class_option :interactive, type: :boolean, aliases: :i, default: false
    class_option :all, type: :boolean, aliases: :a, default: false

    class_options %i[local_dir backup_dir local_sshd_config]

    desc 'fresh_install', 'accepts not arguments, my own personal command'
    def fresh_install
      opts = options.dup
      opts[:yaml_file] = File.join(Dir.home, '.credentials.yaml')
      Copy.all(opts)
      Install.all_install

      Access.provide_credentials(opts.dup)

      VpsCli.errors.each { |error| puts error.message }
    end

    desc 'install_gems', 'runs gem install on all gems in packages.rb'
    def install_gems
      Packages::GEMS.each do |g|
        Rake.sh("gem install #{g}")
      end
    end

    desc 'copy [OPTIONS]', 'Copies files from <vps_cli/config_files>'
    def copy
      Copy.all(options.dup) if options[:all]
    end

    desc 'pull [OPTIONS]', 'Pulls files into your vps_cli repo'
    options %i[dotfiles_dir misc_files_dir]
    def pull
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

    desc 'git_pull', 'Automatically pulls in changes from remote repo'
    def git_pull
      swap_dir { Rake.sh('git pull') }
    end

    desc 'git_push [message]', 'Automatically pushes changes to your remote repo'
    def git_push(message = nil)

      message ||= "auto push files"

      swap_dir do
        Rake.sh('git add -A')
        Rake.sh("git commit -m \"#{message}\"")
        Rake.sh('git push')
      end
    end

    desc 'git_status', 'provides the status of your repo'
    def git_status
      swap_dir { Rake.sh('git status') }
    end

    no_commands do
      def swap_dir
        Rake.cd(PROJECT_DIR)
        yield
      end
    end
  end
end
