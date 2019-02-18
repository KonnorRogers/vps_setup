# frozen_string_literal: true

require 'rake'

require_relative 'file_helper.rb'

module VpsCli
  # Copies config from /vps_cli/dotfiles & vps_cli/miscfiles to your home dir
  class Copy
    extend FileHelper
    # Top level method for copying all files
    # @param [Hash] Provides options for copying files
    # @option opts [Dir] :dest_dir ('Dir.home') Where to save the dotfiles to
    # @option opts [Dir] :backup_dir ('$HOME/backup_files') Where to backup
    #   currently existing dotfiles
    # @option opts [Dir] :local_ssh_dir ('/etc/ssh') directory containing sshd_config
    # @option opts [Boolean] :verbose (false)
    #   Whether or not to print additional info
    # @option opts [Boolean] :testing (false) used internally for minitest
    # @raise [RuntimeError]
    #   Will raise this error if you run this method as root or sudo
    def self.copy(opts = {})
      root = (Process.uid.zero? || Dir.home == '/root')
      root_msg = 'Do not run this as root or sudo. Run as a normal user'
      raise root_msg if root == true

      FileHelper.mkdirs(opts[:dest_dir], opts[:backup_dir])

      copy_dotfiles(opts)

      copy_gnome_settings(opts)
      copy_sshd_config(opts)

      puts "dotfiles copied to #{opts[:dest_dir]}"
      puts "backups created @ #{opts[:backup_dir]}"
    end

    # Copies files from 'dotfiles' directory via the copy_all method
    # Defaults are provided in the VpsCli.create_options method
    # @see #VpsCli.create_options
    # @see #copy_all
    # @param [Hash] Options hash
    # @option opts [Dir] :backup_dir ('$HOME/backup_files)
    #   Directory to place your original dotfiles.
    # @option opts [Dir] :dest_dir ('$HOME') Where to place the dotfiles,
    # @option opts [Dir] :dotfiles_dir ('/path/to/vps_cli/config_files')
    #   Location of files to be copied
    def self.copy_dotfiles(opts = {})
      opts = VpsCli.create_options(opts)

      Dir.each_child(opts[:dotfiles_dir]) do |file|
        config = File.join(opts[:dotfiles_dir], file)
        dot = File.join(opts[:dest_dir], ".#{file}")
        backup = File.join(opts[:backup_dir], "#{file}.orig")

        copy_all(config, dot, backup, opts[:verbose])
      end
    end

    # Checks that sshd_config is able to be copied
    # @param ssh_dir [Dir] Directory containing your original sshd_config
    #   Defaults to /etc/ssh
    # @return [Boolean] Returns true if the ssh_dir exists
    def self.sshd_copyable?(ssh_dir = nil)
      ssh_dir ||= '/etc/ssh'

      no_ssh_dir = 'No ssh dir found. sshd_config not copied'
      return puts no_ssh_dir unless Dir.exist?(ssh_dir)

      true
    end

    # Copies sshd_config to the ssh_dir [/etc/ssh]
    #   This is slightly different from other copy methods in this file
    #   It uses Rake.sh("sudo cp")
    #   Due to copying to /etc/ssh requiring root permissions
    # @options opts [Hash] Set of options for files
    # @option opts [Dir] :backup_dir
    #   Directory for backing up your original sshd_config file
    #   Defaults to $HOME/backup_files
    # @option opts [Dir] :local_ssh_dir Directory containing your sshd_config file
    #   Defaults to /etc/ssh
    # @option opts [File] :misc_files_dir Directory to pull misc files from
    def self.copy_sshd_config(opts = {})
      opts = VpsCli.create_options(opts)
      opts[:local_ssh_dir] ||= '/etc/ssh'

      return unless sshd_copyable?(opts[:local_ssh_dir])

      opts[:sshd_backup] ||= File.join(opts[:backup_dir], 'sshd_config.orig')
      # local_sshd_path ||= File.join(opts[:local_ssh_dir], 'sshd_config')
      local_sshd_path = File.join(opts[:local_ssh_dir], 'sshd_config')

      misc_sshd_path = File.join(opts[:misc_files_dir], 'sshd_config')

      if File.exist?(local_sshd_path) && !File.exist?(opts[:sshd_backup])
        Rake.cp(local_sshd_path, opts[:sshd_backup])
      else
        puts "#{opts[:sshd_backup]} already exists. no backup created"
      end

      if opts[:testing]
        Rake.cp(misc_sshd_path, local_sshd_path)
      else
        # This method must be run this way due to it requiring root privileges
        Rake.sh("sudo cp #{misc_sshd_path} #{local_sshd_path}")
      end
    end


    ##
    # Deciphers between files & directories
    # @param config_file [File] The file from the repo to be copied locally
    # @param local_file [File] The file that is currently present locally
    # @param backup_file [File]
    #   The file to which to save the currently present local file
    def self.copy_all(config_file, local_file, backup_file, verbose = false)
      if File.directory?(config_file)
        FileHelper.copy_dirs(config_file, local_file, backup_file, verbose)
      else
        FileHelper.copy_files(config_file, local_file, backup_file, verbose)
      end
    end


    ##
    # Copies gnome terminal via dconf
    # @see https://wiki.gnome.org/Projects/dconf dconf wiki
    # @param backup_dir [File] Where to save the current gnome terminal settings
    # @note This method will raise an error if dconf errors out
    #   The error will be saved to VpsCli.errors
    def self.copy_gnome_settings(opts = {})
      backup = "#{opts[:backup_dir]}/gnome_terminal_settings.orig"

      # This is the ONLY spot for gnome terminal
      gnome_path = '/org/gnome/terminal/'

      raise RuntimeError if opts[:testing]

      Rake.sh("dconf dump #{gnome_path} > #{backup}")

      Rake.sh("dconf load #{gnome_path} < #{FILES_DIR}/gnome_terminal_settings")
    rescue RuntimeError => error
      puts 'something went wrong with gnome, continuing on' if opts[:verbose]
      VpsCli.errors << error
    end
  end
end
