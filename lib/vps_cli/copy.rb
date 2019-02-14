# frozen_string_literal: true

require 'rake'

module VpsCli
  # Copies config from /vps_cli/dotfiles & vps_cli/miscfiles to your home dir
  class Copy
    # Top level method for copying all files
    # @param [Hash] Provides options for copying files
    # @option opts [Dir] :dest_dir ('Dir.home') Where to save the dotfiles to
    # @option opts [Dir] :backup_dir ('$HOME/backup_files') Where to backup
    #   currently existing dotfiles
    # @option opts [Dir] :ssh_dir ('/etc/ssh') directory containing sshd_config
    # @option opts [Boolean] :verbose (false)
    #   Whether or not to print additional info
    # @option opts [Boolean] :testing (false) used internally for minitest
    # @raise [RuntimeError]
    #   Will raise this error if you run this method as root or sudo
    def self.copy(opts = {})
      root = (Process.uid.zero? || Dir.home == '/root')
      root_msg = 'Do not run this as root or sudo. Run as a normal user'
      raise root_msg if root == true

      mkdirs(opts[:dest_dir], opts[:backup_dir])

      copy_dotfiles(opts)

      copy_gnome_settings(opts)
      copy_sshd_config(opts)

      puts "dotfiles copied to #{opts[:dest_dir]}"
      puts "backups created @ #{opts[:backup_dir]}"
    end

    # Copies files from 'dotfiles' directory via the copy_all method
    # Defaults are provided in the create_options method
    # (see ::create_options)
    # (see ::copy_all)
    # @param [Hash] Options hash
    # @option opts [Dir] :backup_dir ('$HOME/backup_files)
    #   Directory to place your original dotfiles.
    # @option opts [Dir] :dest_dir ('$HOME') Where to place the dotfiles,
    # @option opts [Dir] :dotfiles_dir ('/path/to/vps_cli/config_files')
    #   Location of files to be copied
    def self.copy_dotfiles(opts = {})
      opts = create_options(opts)

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
    # @option opts [Dir] :ssh_dir Directory containing your sshd_config file
    #   Defaults to /etc/ssh
    def self.copy_sshd_config(opts = {})
      opts = create_options(opts)
      opts[:ssh_dir] ||= '/etc/ssh'


      return unless sshd_copyable?(opts[:ssh_dir])

      opts[:sshd_cfg_path] ||= File.join(FILES_DIR, 'sshd_config')
      opts[:sshd_backup] ||= File.join(opts[:backup_dir], 'sshd_config.orig')
      opts[:sshd_path] ||= File.join(opts[:ssh_dir], 'sshd_config')

      if File.exist?(opts[:sshd_path]) && !File.exist?(opts[:sshd_backup])
        Rake.cp(opts[:sshd_path], opts[:sshd_backup])
      else
        puts "#{opts[:sshd_backup]} already exists. no backup created"
      end

      if opts[:testing]
        Rake.cp(opts[:sshd_cfg_path], opts[:sshd_path])
      else
        # This method must be run this way due to it requiring root privileges
        Rake.sh("sudo cp #{opts[:sshd_cfg_path]} #{opts[:sshd_path]}")
      end
    end

    # Default way of checking if the dotfile already exists
    # @param file [File] File to be searched for
    # @param verbose [Boolean] Will print to console if verbose == true
    # @return [Boolean] Returns true if the file exists
    def self.dot_file_found?(file, verbose = false)
      return true if File.exist?(file)

      puts "#{file} does not exist. No backup created." if verbose
      false
    end

    # Checks that a backup file does not exist
    # @param file [File] File to be searched for
    # @param verbose [Boolean] Will print to console if verbose == true
    # @return [Boolean] Returns true if the file is not found
    def self.backup_file_not_found?(file, verbose = false)
      return true unless File.exist?(file)

      puts "#{file} exists already. No backup created." if verbose
      false
    end

    # Deciphers between files & directories
    # @param config_file [File] The file from the repo to be copied locally
    # @param dot_file [File] The file that is currently present locally
    # @param backup_file [File]
    #   The file to which to save the currently present local file
    def self.copy_all(config_file, dot_file, backup_file, verbose = false)
      if File.directory?(config_file)
        copy_dirs(config_file, dot_file, backup_file, verbose)
      else
        copy_files(config_file, dot_file, backup_file, verbose)
      end
    end

    # Copies files, called by copy_all
    # @param config_file [File] The file from the repo to be copied locally
    # @param dot_file [File] The file that is currently present locally
    # @param backup_file [File]
    #   The file to which to save the currently present local file
    # @param verbose [Boolean] Will print more info to terminal if true
    def self.copy_files(config_file, dot_file, backup_file, verbose = false)
      # if there is an original dot file & no backup file in the backupdir
      # Copy the dot file to the backup dir
      if create_backup?(dot_file, backup_file, verbose)
        Rake.cp(dot_file, backup_file)
      end

      # Copies from vps_cli/dotfiles to the location of the dot_file
      Rake.cp(config_file, dot_file)
    end

    # Copies directories instead of file
    # @param config_file [Dir] The Dir from the repo to be copied locally
    # @param dot_file [Dir] The Dir that is currently present locally
    # @param backup_file [Dir]
    #   The Dir to which to save the currently present local file
    # @param verbose [Boolean] Will print additional info to terminal if true
    def self.copy_dirs(config_dir, dot_dir, backup_dir, verbose = false)
      if create_backup?(dot_dir, backup_dir, verbose)
        Rake.cp_r(dot_dir, backup_dir)
      end

      Rake.mkdir_p(dot_dir) unless Dir.exist?(dot_dir)

      Dir.each_child(config_dir) do |c_dir|
        c_dir = File.join(config_dir, c_dir)

        Rake.cp_r(c_dir, dot_dir)
      end
    end

    # Helper method for determining whether or not to create a backup file
    # @param dot_file [File] current dot file
    # @param backup_file [File] Where to back the dot file up to
    # @param verbose [Boolean] Will print to terminal if verbose == true
    # @return [Boolean] Returns true if there is a dotfile that exists
    #   And there is no current backup_file found
    def self.create_backup?(dot_file, backup_file, verbose = false)
      return false unless dot_file_found?(dot_file, verbose)
      return false unless backup_file_not_found?(backup_file, verbose)

      true
    end

    # @return [Hash] Returns the options hash
    def self.create_options(opts)
      opts[:backup_dir] ||= File.join(Dir.home, 'backup_files')
      opts[:dest_dir] ||= Dir.home
      opts[:dotfiles_dir] ||= DOTFILES_DIR
      opts[:ssh_dir] ||= '/etc/ssh'
      opts[:verbose] ||= false

      opts
    end

    # Helper method for making multiple directories
    # @param [Dir, Array<Dir>] Creates either one, or multiple directories
    def self.mkdirs(*dirs)
      dirs.flatten.each { |dir| Rake.mkdir_p(dir) unless Dir.exist?(dir) }
    end

    # Copies gnome terminal via dconf
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
