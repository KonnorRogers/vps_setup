# frozen_string_literal: true

require 'fileutils'
require 'os' # returns users OS

module VPS_Setup
  # Copies config from /vps-setup/config to your home dir
  class Copy

    def self.copy(backup_dir:, dest_dir:, attr: {})
      attr[:posix] ||= OS.posix?
      raise 'Please run from a posix platform' unless attr[:posix] == true

      attr[:root] ||= (Process.uid.zero? && Dir.home == '/root')
      raise 'Do not run this as root, use sudo instead' if attr[:root] == true

      mkdirs(backup_dir, dest_dir)

      copy_config_dir(backup_dir, dest_dir, attr)

      puts "dotfiles copied to #{dest_dir}."
      puts "backups created @ #{backup_dir}."
    end

    def self.copy_config_dir(backup_dir, dest_dir, attr = {})
      # Dir.children(CONFIG_DIR).each do |file|, released in ruby 2.5.1
      # in 2.3.3 which is shipped with babun
      Dir.foreach(CONFIG_DIR).each do |file|
        # Explanation of this regexp in test/test_copy_confib.rb
        # .for_each returns '.' and '..' which we dont want
        next if file =~ /\A\.{1,2}\Z/

        config = File.join(CONFIG_DIR, file)
        dot = File.join(dest_dir, ".#{file}")
        backup = File.join(backup_dir, ".#{file}.orig")

        if OS.linux?
          copy_unix_files(config, dot, backup)
          copy_sshd_config(backup_dir) && next if file == 'sshd_config'
        end
        copy_cygwin_files(config, dot, backup) if OS.cygwin?
        # only copies if sudo, linux, and ssh_path exists
      end
    end

    def self.sshd_copyable?(ssh_dir = nil, process_uid = nil)
      process_uid ||= Process.uid.zero?
      ssh_dir ||= '/etc/ssh'

      not_sudo = 'not running process as sudo, will sshd_config not copied'
      return puts not_sudo if process_uid != true

      no_ssh_dir = 'No ssh dir found. sshd_config not copied'
      return puts no_ssh_dir unless Dir.exist?(ssh_dir)

      true
    end

    def self.copy_sshd_config(backup_dir, sshd_path)
      return unless sshd_copyable?

      sshd_cfg_path = File.join(CONFIG_DIR, 'sshd_config')
      sshd_path ||= '/etc/ssh/sshd_config'
      sshd_backup = File.join(backup_dir, 'sshd_config.orig')

      FileUtils.cp(sshd_path, sshd_backup) if File.exist?(sshd_path)
      puts "copying to #{sshd_path}"
      FileUtils.cp(sshd_cfg_path, sshd_path)
    end

    def self.dot_file_found?(file)
      return true if File.exist?(file)

      puts "#{file} does not exist. No backup created."
      false
    end

    def self.backup_file_not_found?(file)
      return true unless File.exist?(file)

      puts "#{file} exists already. No backup created."
      false
    end

    # helper method to run within a file list
    def self.copy_unix_files(config_file, dot_file, backup_file)
      non_unix_files = %w[cygwin_zshrc minttyrc]
      return if non_unix_files.include?(File.basename(config_file))

      copy_files(config_file, dot_file, backup_file)
    end

    def self.copy_cygwin_files(config_file, dot_file, backup_file, cygwin = nil)
      cygwin ||= OS.cygwin?
      puts 'you are running on cygwin' && return unless cygwin == true

      non_cygwin_files = %w[zshrc]
      return if non_cygwin_files.include?(File.basename(config_file))

      if File.basename(config_file) == 'cygwin_zshrc'
        # Converts cygwin_zshrc to .zshrc for cygwin environment use
        dot_file = File.join(File.dirname(dot_file), '.zshrc')
        backup_file = File.join(File.dirname(backup_file), '.zshrc.orig')
      end

      copy_files(config_file, dot_file, backup_file)
    end

    def self.copy_files(config_file, dot_file, backup_file)
      # if there is an original dot file & no backup file in the backupdir
      if dot_file_found?(dot_file)
        if backup_file_not_found?(backup_file)
          # Copy the dot file to the backup dir
          FileUtils.cp(dot_file, backup_file)
        end
      end

      # Copies from vps-setup/config to home_dir
      FileUtils.cp(config_file, dot_file)
    end

    def self.mkdirs(*dirs)
      dirs.each { |dir| FileUtils.mkdir_p(dir) unless Dir.exist?(dir) }
    end
  end
end
