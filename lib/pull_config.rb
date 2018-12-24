# frozen_string_literal: true

require 'fileutils'
require 'copy_config'
require 'os'

class PullChanges
  def self.config_dotfiles(attr = {})
    config_dir = attr[:config_dir] ||= CopyConfig::CONFIG_DIR
    cygwin = attr[:cygwin] ||= OS.cygwin?

    dot_files = %w[pryrc tmux.conf vimrc zshrc]
    dot_files << 'minttyrc' if cygwin

    Dir.foreach(config_dir).select { |file| dot_files.include?(file) }
  end

  # Must use foreach due to not having Dir.children in 2.3.3 for babun
  def self.copy_dotfiles(attr = {})
    dotfiles = config_dotfiles
    config_files = dotfiles.map { |file| file.delete_prefix('.') }

    Dir.foreach(local_dir) do |l_file|
      next unless dotfiles.include?(file)

      Dir.foreach(config_files) do |c_file|
        next unless config_files.include?(c_file)
        next unless c_file == l_file.delete_prefix('.')

        # Copies from local to config file
        local_file = File.join(local_dir, l_file)
        config_file = File.join(config_dir, c_file)
        FileUtils.cp(local_file, config_file)
      end
    end

    local_dir = attr[:local_dir] ||= Dir.home
    config_dir = attr[:config_dir] ||= CopyConfig::CONFIG_DIR
    linux = attr[:linux] ||= OS.linux?
    cygwin = attr[:cygwin] ||= OS.cygwin?

    Dir.foreach(local_dir) do |l_file|
      Dir.foreach(config_dir) do |c_file|

      end
    end

  end

  def self.copy_sshd_config
    sshd_local_path = '/etc/ssh/sshd_config'
    sshd_config_path = File.join(CopyConfig::CONFIG_DIR, 'sshd_config')
    FileUtils.cp(sshd_local_path, sshd_config_path)
  end
end
