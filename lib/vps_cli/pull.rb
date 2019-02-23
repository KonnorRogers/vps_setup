# frozen_string_literal: true

require 'rake'

module VpsCli
  # Pull changes from local dir into config dir
  # to be able to push changes up to the config dir
  class Pull
    # Base pull method
    # @see VpsCli#create_options for the defaults
    # @param opts [Hash] Provides options for pulling files into a
    #   specific destination directory
    # @options opts [Dir] :local_dir ('$HOME')
    #   Where the local dotfiles are located
    # @option opts [Dir] :dotfiles_dir
    #   ('/path/to/vps_cli/config_files/dotfiles') Where to save the dotfiles to
    # @option opts [Dir] :misc_files_dir
    #   ('/path/to/vps_cli/config_files/misc_files')
    # @option opts [Dir] :backup_dir ('$HOME/backup_files') Where to backup
    #   currently existing dotfiles
    # @option opts [File] :local_sshd_config ('/etc/ssh/sshd_config')
    #   directory containing sshd_config
    # @option opts [Boolean] :verbose (false)
    #   Whether or not to print additional info

    def self.all(opts = {})
      opts = VpsCli.create_options(opts)

      # pulls dotfiles into specified directory
      dotfiles(opts)

      # pulls from opts[:local_sshd_config]
      sshd_config(opts)

      # pulls via dconf
      gnome_terminal_settings(opts)
    end

    # @see VpsCli#create_options for defaults
    # @param opts [Hash] Provides options for pulling dotfiles
    # @options opts [Dir] :local_dir ('$HOME') Where the dotfiles are locally
    # @options opts [Dir] :dotfiles_dir
    #   ('/path/to/vps_cli/config_files/dotfiles')
    #   location of the dotfiles to be modified
    # @options opts [Dir] :verbose (false)

    def self.dotfiles(opts = {})
      opts = VpsCli.create_options(opts)

      Dir.each_child(opts[:dotfiles_dir]) do |remote_file|
        Dir.each_child(opts[:local_dir]) do |local_file|
          # keep iterating until the remote_file and local file are the same
          next unless local_file == ".#{remote_file}"

          if File.directory?(remote_file)
            Rake.cp_r(local_file, remote_file)
          else
            Rake.cp(local_file, remote_file)
          end

          puts "Copying #{local_file} to #{remote_file}"
        end
      end
    end

    # @see VpsCli#create_options for the defaults
    # @param opts [Hash] Provides options for pulling files into a
    #   specific destination directory
    # @option opts [File] :local_sshd_config ('/etc/ssh/sshd_config')
    #   directory containing sshd_config
    # @option opts [Dir] :misc_files_dir
    #   ('/path/to/vps_cli/config_files/misc_files')
    # @option opts [Boolean] :verbose (false)
    #   Whether or not to print additional info
    def self.sshd_config(opts = {})
      opts = VpsCli.create_options(opts)

      Rake.cp(opts[:local_sshd_config], opts[:misc_files_dir])
      puts "Copied #{opts[:local_sshd_config]} to #{opts[:misc_files_dir]}"
    end

    # @see VpsCli#create_options for defaults
    # @param options [Hash] Provides options for pulling your gnome config
    # @option opts [Dir] :misc_files_dir
    #   ('/path/to/vps_cli/misc_files/gnome_terminal_settings')
    #   Where to save gnome settings
    # @option opts [Boolean] :verbose
    def self.gnome_terminal_settings(opts = {})
      opts = VpsCli.create_options(opts)

      # This is where dconf stores gnome terminal
      gnome_dconf = '/org/gnome/terminal/'
      remote_settings = File.join(opts[:misc_files_dir],
                                  'gnome_terminal_settings')

      orig_remote_contents = File.read(remote_settings)

      Rake.sh("dconf dump #{gnome_dconf} > #{remote_settings}")
    rescue RuntimeError => error
      VpsCli.errors << error
      # if dconf errors, it will erase the config file contents
      # So this protects against that
      reset_to_original(remote_settings, orig_remote_contents)
    else
      puts "Successfully dumped Gnome into #{remote_settings}" if opts[:verbose]
    end
  end
end
