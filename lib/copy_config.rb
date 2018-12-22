# frozen_string_literal: true

require 'fileutils'
require 'os'
require 'logger'

# Copies config from /vps-setup/config to your home dir
class CopyConfig
  ROOT = File.expand_path(File.expand_path('../', __dir__))
  CONFIG_DIR = File.join(ROOT, 'config')

  def self.copy(backup_dir:, dest_dir:)
    puts 'Please run from a posix platform' unless OS.posix?

    mkdirs(backup_dir, dest_dir)

    Dir.children(CONFIG_DIR).each do |file|
      config = File.join(CONFIG_DIR, file)
      dot = File.join(dest_dir, ".#{file}")
      backup = File.join(backup_dir, ".#{file}.orig")

      copy_unix_files(config, dot, backup)
      copy_cygwin_files(config, dot, backup)
    end

    puts "dotfiles copied to #{dest_dir}."
    puts "backups created @ #{backup_dir}."
  end

  # TODO: Add test, may be better to allow users to do on their own or place with initial sudo bash script
  def self.copy_sshd_config(backup_dir)
    return unless sshd_copyable?

    sshd_config_path = File.join(File.expand_path('../', __dir__), 'sshd_config')
    sshd_path = '/etc/ssh/sshd_config'
    sshd_backup = File.join(backup_dir, 'sshd_config.orig')

    FileUtils.cp(sshd_path, sshd_backup) if File.exist?(sshd_path)
    FileUtils.cp(sshd_config_path, '/etc/ssh/sshd_config')
  end

  def self.sshd_copyable?
    not_linux = 'You are not running on linux. sshd_config not copied'
    # do the same for the other 2
    return (puts not_linux || false) unless OS.linux?
    return false unless Dir.exist?('/etc/ssh')
    # checks if running as root
    return false unless Process.uid == 0

    true
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

  def self.copy_unix_files(config_file, dot_file, backup_file)
    puts 'you are running on mac or linux' && return unless OS.mac? || OS.linux?

    non_unix_files = %w[cygwin_zshrc minttyrc]
    return if non_unix_files.include?(File.basename(config_file))

    copy_files(config_file, dot_file, backup_file)
  end

  def self.copy_cygwin_files(config_file, dot_file, backup_file)
    puts 'you are running on cygwin' && return unless OS.cygwin?

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
