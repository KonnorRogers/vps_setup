# frozen_string_literal: true

require 'fileutils'

# Copies config from /vps-setup/config to your home dir
class CopyConfig
  CONFIG_DIR = File.join(File.expand_path('../', __dir__), 'config')

  def copy(backup_dir:, dest_dir:, test: false)
    FileUtils.mkdir_p(backup_dir) unless Dir.exist?(backup_dir)
    FileUtils.mkdir_p(dest_dir) unless Dir.exist?(dest_dir)

    Dir.children(CONFIG_DIR).each do |file|
      config_file = File.join(CONFIG_DIR, file)

      dot_file = File.join(dest_dir, ".#{file}")
      backup_file = File.join(backup_dir, "#{dot_file}.orig")

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

    puts "dotfiles copied to #{dest_dir}." if test == false
    puts "backups created @ #{backup_dir}." if test == false
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
end
