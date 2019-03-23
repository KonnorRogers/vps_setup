# frozen_string_literal: true

require 'rake'

require 'vps_cli/copy_helper'

module VpsCli
  # Copies config from /vps_cli/config_files/dotfiles
  #   & vps_cli/config_files/miscfiles to your home dir
  class Copy
    extend FileHelper
    # Top level method for copying all files
    # @param [Hash] Provides options for copying files
    # @option opts [Dir] :local_dir ('Dir.home') Where to save the dotfiles to
    # @option opts [Dir] :backup_dir ('$HOME/backup_files') Where to backup
    #   currently existing dotfiles
    # @option opts [File] :local_sshd_config ('/etc/ssh/sshd_config')
    #   directory containing sshd_config
    # @option opts [Boolean] :verbose (false)
    #   Whether or not to print additional info
    # @option opts [Boolean] :interactive (true)
    #   Before overwriting any file, it will ask permission to overwrite.
    #   It will also still create the backup
    # @option opts [Boolean] :testing (false) used internally for minitest
    # @raise [RuntimeError]
    #   Will raise this error if you run this method as root or sudo
    def self.all(opts = {})
      root = (Process.uid.zero? || Dir.home == '/root')
      root_msg = 'Do not run this as root or sudo. Run as a normal user'
      raise root_msg if root == true

      opts = VpsCli.create_options(opts)
      FileHelper.mkdirs(opts[:local_dir], opts[:backup_dir])

      dotfiles(opts)

      gnome_settings(opts)
      sshd_config(opts)

      puts "dotfiles copied to #{opts[:local_dir]}"
      puts "backups created @ #{opts[:backup_dir]}"
    end

    # Copy files from 'config_files/dotfiles' directory via the copy_all method
    # Defaults are provided in the VpsCli.create_options method
    # @see #VpsCli.create_options
    # @see #all
    # @param [Hash] Options hash
    # @option opts [Dir] :backup_dir ('$HOME/backup_files)
    #   Directory to place your original dotfiles.
    # @option opts [Dir] :local_dir ('$HOME') Where to place the dotfiles,
    # @option opts [Dir] :dotfiles_dir ('/path/to/vps_cli/dotfiles')
    #   Location of files to be copied
    def self.dotfiles(opts = {})
      opts = VpsCli.create_options(opts)

      Dir.each_child(opts[:dotfiles_dir]) do |file|
        config = File.join(opts[:dotfiles_dir], file)
        dot = File.join(opts[:local_dir], ".#{file}")
        backup = File.join(opts[:backup_dir], "#{file}.orig")

        files_and_dirs(config, dot, backup, opts[:verbose])
        files_and_dirs(config_file: config,
                       local_file: dot,
                       backup_file: backup,
                       verbose: opts[:verbose],
                       interactive: opts[:interactive])
      end
    end

    # Checks that sshd_config is able to be copied
    # @param sshd_config [File] File containing your original sshd_config
    #   Defaults to /etc/ssh/sshd_config
    # @return [Boolean] Returns true if the sshd_config exists
    def self.sshd_copyable?(sshd_config = nil)
      sshd_config ||= '/etc/ssh/sshd_config'

      no_sshd_config = 'No sshd_config found. sshd_config not copied'

      return true if File.exist?(sshd_config)

      VpsCli.errors << no_sshd_config
    end

    # Copies sshd_config to the local_sshd_config location
    #   Defaults to [/etc/ssh/sshd_config]
    #   This is slightly different from other copy methods in this file
    #   It uses Rake.sh("sudo cp")
    #   Due to copying to /etc/ssh/sshd_config requiring root permissions
    # @options opts [Hash] Set of options for files
    # @option opts [Dir] :backup_dir ($HOME/backup_files)
    #   Directory for backing up your original sshd_config file
    # @option opts [File] :local_sshd_config (/etc/ssh/sshd_config)
    #   File containing your original sshd_config file
    # @option opts [File] :misc_files_dir
    #   (/path/to/vps_cli/config_files/miscfiles)
    #   Directory to pull sshd_config from
    def self.sshd_config(opts = {})
      opts = VpsCli.create_options(opts)

      opts[:local_sshd_config] ||= File.join('/etc', 'ssh', 'sshd_config')
      return unless sshd_copyable?(opts[:local_sshd_config])

      opts[:sshd_backup] ||= File.join(opts[:backup_dir], 'sshd_config.orig')

      misc_sshd_path = File.join(opts[:misc_files_dir], 'sshd_config')

      if File.exist?(opts[:local_sshd_config]) && !File.exist?(opts[:sshd_backup])
        Rake.cp(opts[:local_sshd_config], opts[:sshd_backup])
      else
        puts "#{opts[:sshd_backup]} already exists. no backup created"
      end

      return Rake.cp(misc_sshd_path, opts[:local_sshd_config]) if opts[:testing]

      # This method must be run this way due to it requiring root privileges
      Rake.sh("sudo cp #{misc_sshd_path} #{opts[:local_sshd_config]}")
    end

    # Deciphers between files & directories
    # @see VpsCli::FileHelper#copy_dirs
    # @see VpsCli::FileHelper#copy_files
    def self.files_and_dirs(opts = {})
      if File.directory?(opts[:config_file])
        FileHelper.copy_dirs(opts)
      else
        FileHelper.copy_files(opts)
      end
    end

    # Copies gnome terminal via dconf
    # @see https://wiki.gnome.org/Projects/dconf dconf wiki
    # @param backup_dir [File] Where to save the current gnome terminal settings
    # @note This method will raise an error if dconf errors out
    #   The error will be saved to VpsCli.errors
    def self.gnome_settings(opts = {})
      backup = "#{opts[:backup_dir]}/gnome_terminal_settings.orig"

      # This is the ONLY spot for gnome terminal
      gnome_path = '/org/gnome/terminal/'

      raise RuntimeError if opts[:testing]

      Rake.sh("dconf dump #{gnome_path} > #{backup}")

      Rake.sh("dconf load #{gnome_path} < #{MISC_FILES_DIR}/gnome_terminal_settings")
    rescue RuntimeError => error
      puts 'something went wrong with gnome, continuing on' if opts[:verbose]
      VpsCli.errors << error
    end
  end
end
