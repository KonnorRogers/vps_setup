# frozen_string_literal: true

require 'fileutils'
require 'os'
require 'rake'

# NON_DOTFILES & variation constants defined in lib/vps_setup.rb

module VpsSetup
  # Pull changes from local dir into config dir
  # to be able to push changes up to the config dir
  class Pull
    def self.pull_all(attr = {})
      pull_all_linux(attr) if OS.linux?
      pull_all_cygwin(attr) if OS.cygwin?
    end

    def self.pull_all_linux(attr = {})
      linux_config_dotfiles_ary(attr[:cfg_dir]).each do |config|
        linux_local_dotfiles_ary(attr[:local_dir]).each do |local|

          FileUtils.cp(local, config) if config.prepend('.') == local
        end
      end

      pull_sshd_config(attr[:sshd_local], attr[:sshd_config])
      pull_gnome_term_settings(attr[:gnome_local], attr[:gnome_config])
    end

    def self.pull_all_cygwin(attr = {})
      cygwin_config_dotfiles_ary(attr[:cfg_dir]).each do |config|
        cygwin_local_dotfiles_ary(attr[:local_dir]).each do |local|
          if config.prepend('.') == local
            FileUtils.cp(File.join(attr[:local_dir], local), File.join(attr[:cfg_dir], config))
            puts "Copying #{local} to #{config}"
          end


          next unless config == 'cygwin_zshrc' && local == '.zshrc'

          attr[:cfg_dir] ||= CONFIG_DIR
          cygwin_zshrc = File.join(attr[:cfg_dir], 'cygwin_zshrc')
          FileUtils.cp(File.join(attr[:cfg_dir], local), cygwin_zshrc)
          puts "Copying #{local} to #{cygwin_zshrc}"
          attr[:cfg_dir] = nil
        end
      end

    end

    # Must use foreach due to not having Dir.children in 2.3.3 for babun
    def self.linux_config_dotfiles_ary(dir = CONFIG_DIR)
      Dir.entries(dir).reject do |file|
        NON_LINUX_DOTFILES.include?(file) || file =~ /\A\.{1,2}\Z/
      end
      # only returns dotfiles for linux
    end

    def self.cygwin_config_dotfiles_ary(dir = CONFIG_DIR)
      Dir.entries(dir).reject do |file|
        # removes '.' && '..'
        NON_CYGWIN_DOTFILES.include?(file) || file =~ /\A\.{1,2}\Z/
      end
      # returns cygwin dotfiles
    end

    # *local_dotfiles_ary returns the files w/ a '.', ex: .vimrc
    def self.cygwin_local_dotfiles_ary(local_dir = Dir.home)
      cygwin_config_dotfiles_ary(local_dir).map do |file|
        # need to convert for use with babun / cygwin
        if file == 'cygwin_zshrc'
          '.zshrc'
        else
          file.prepend('.')
        end
      end
    end

    def self.linux_local_dotfiles_ary(local_dir = Dir.home)
      linux_config_dotfiles_ary(local_dir).map { |file| file.prepend('.') }
    end

    def self.pull_sshd_config(sshd_local_path = nil, sshd_config_path = nil)
      sshd_local_path ||= '/etc/ssh/sshd_config'
      sshd_config_path ||= File.join(CONFIG_DIR, 'sshd_config')

      # checks that there is a file to copy
      error = "#{sshd_local_path} does not exist. sshd_config not copied to cfg"
      return puts error unless File.exist?(sshd_local_path)

      FileUtils.cp(sshd_local_path, sshd_config_path)
    end

    def self.pull_gnome_term_settings(local_term = nil, config_term = nil)
      local_term ||= '/org/gnome/terminal/'
      config_term ||= File.join(CONFIG_DIR, 'gnome_terminal_settings')

      local_error = "#{local_term} does not exist. No copy created of gnome settings"
      return puts local_error unless File.exist?(local_term)

      config_error = "#{config_term} does not exist. Gnome settings not pulled."
      return puts config_error unless File.exist?(config_term)

      gnome_dump(local_term, config_term)
    end

    def self.gnome_dump(local_term, config_term)
      Rake.sh("dconf dump #{local_term} > #{config_term}")
    rescue RuntimeError
      puts 'it appears you dont have dconf installed.'
      puts 'skipping dumping of gnome_settings'
      puts 'To install dconf, simply use'
      puts 'sudo apt-get install dconf-tools'
      false
    else
      puts "Gnome settings successfully dumped into #{config_term}"
      true
    end
  end
end
