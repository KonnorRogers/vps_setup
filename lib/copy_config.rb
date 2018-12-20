# frozen_string_literal: true

require 'fileutils'
require 'os'

# Copies config from /vps-setup/config to your home dir
class CopyConfig
  CONFIG_DIR = File.join(File.expand_path('../', __dir__), 'config')

  def copy(backup_dir:, dest_dir:, test: false)
    puts 'Please run from a posix platform' unless OS.posix?

    mkdirs(backup_dir, dest_dir)

    Dir.children(CONFIG_DIR).each do |file|
      config = File.join(CONFIG_DIR, file)
      dot = File.join(dest_dir, ".#{file}")
      backup = File.join(backup_dir, ".#{file}.orig")

      copy_unix_files(config, dot, backup, test)
      copy_cygwin_files(config, dot, backup, test)
    end

    puts "dotfiles copied to #{dest_dir}." if test == false
    puts "backups created @ #{backup_dir}." if test == false
  end

  # TODO: Add test, may be better to allow users to do on their own or place with initial sudo bash script
  def copy_sshd_config(backup_dir)
    return unless sshd_copyable?

    sshd_config_path = File.join(File.expand_path('../', __dir__), 'sshd_config')
    sshd_path = '/etc/ssh/sshd_config'
    sshd_backup = File.join(backup_dir, 'sshd_config.orig')

    FileUtils.cp(sshd_path, sshd_backup) if File.exist?(sshd_path)
    FileUtils.cp(sshd_config_path, '/etc/ssh/sshd_config')
  end

  private

  def sshd_copyable?
    linux = 'You are not running on linux. sshd_config not copied'
    # do the same for the other 2
    return (puts linux || false) unless OS.linux?
    return false unless Dir.exist?('/etc/ssh')
    # checks if running as root
    return false unless Process.uid == 0

    true
  end

  def dot_file_found?(file, test = false)
    return true if File.exist?(file)

    puts "#{file} does not exist. No backup created." if test == false
    false
  end

  def backup_file_not_found?(file, test = false)
    return true unless File.exist?(file)

    puts "#{file} exists already. No backup created." if test == false
    false
  end

  def copy_unix_files(config_file, dot_file, backup_file, test = false)
    puts 'you are running on mac or linux' && return unless OS.mac? || OS.linux?

    non_unix_files = %w[cygwin_zshrc minttyrc]
    return if non_unix_files.include?(File.basename(config_file))

    copy_files(config_file, dot_file, backup_file, test)
  end

  def copy_cygwin_files(config_file, dot_file, backup_file, test = false)
    puts 'you are running on cygwin' && return unless OS.cygwin?

    non_cygwin_files = %w[zshrc]
    return if non_cygwin_files.include?(File.basename(config_file))

    if File.basename(config_file) == 'cygwin_zshrc'
      # Converts cygwin_zshrc to .zshrc for cygwin environment use
      dot_file = File.join(File.dirname(dot_file), '.zshrc')
      backup_file = File.join(File.dirname(backup_file), '.zshrc.orig')
    end

    copy_files(config_file, dot_file, backup_file, test)
  end

  def copy_files(config_file, dot_file, backup_file, test = false)
    # if there is an original dot file & no backup file in the backupdir
    if dot_file_found?(dot_file, test)
      if backup_file_not_found?(backup_file, test)
        # Copy the dot file to the backup dir
        FileUtils.cp(dot_file, backup_file)
      end
    end

    # Copies from vps-setup/config to home_dir
    FileUtils.cp(config_file, dot_file)
  end

  def mkdirs(*dirs)
    dirs.each { |dir| FileUtils.mkdir_p(dir) unless Dir.exist?(dir) }
  end
end
