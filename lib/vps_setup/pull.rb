# frozen_string_literal: true

require 'fileutils'
require 'os'

# NON_DOTFILES & variation constants defined in lib/vps_setup.rb

module VpsSetup
  # Pull changes from local dir into config dir to be able to push changes up to repo
  class Pull
    # Must use foreach due to not having Dir.children in 2.3.3 for babun
    def self.linux_config_dotfiles_ary(cfg_dir = CONFIG_DIR)
      cfg_dir.reject { |file| NON_LINUX_DOTFILES.include?(file) }
      # only returns dotfiles for linux
    end

    def self.cygwin_config_dotfiles_ary(cfg_dir = CONFIG_DIR)
      cfg_dir.reject { |file| NON_CYGWIN_DOTFILES.include?(file) }
      # returns cygwin dotfiles
    end

    def self.cygwin_local_dotfiles_ary(local_dir = Dir.home)
      cygwin_files.map do |file|
        file = 'zshrc' if file == 'cygwin_zshrc' # need to convert for use with babun / cygwin
        file.prepend('.')
      end
    end

    def self.linux_local_dotfiles_ary(local_dir = Dir.home)
      linux_config_dotfiles.map { |file| file.prepend('.') }
    end

    def self.copy_sshd_config(sshd_local_path = '/etc/ssh/sshd_config')
      sshd_local_path ||= '/etc/ssh/sshd_config'
      sshd_config_path = File.join(CONFIG_DIR, 'sshd_config')
      FileUtils.cp(sshd_local_path, sshd_config_path)
    end

    def self.copy_gnome_terminal_settings
      # needs testing
    end
  end
end
