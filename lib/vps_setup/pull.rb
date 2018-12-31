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
      cfg_dir = attr[:cfg_dir]
      Rake.mkdir_p(File.expand_path(cfg_dir)) unless cfg_dir.nil? || Dir.exist?(cfg_dir)
      # checks for a blank dir, allows for pulling from vps_setup/config for testing output
      attr[:cfg_dir] = CONFIG_DIR if Dir.entries(cfg_dir).size == 2

      pull_all_linux(attr) if OS.linux?
      pull_all_cygwin(attr) if OS.cygwin?
    end

    def self.pull_all_linux(attr = {})
      attr[:cfg_dir] ||= CONFIG_DIR
      attr[:local_dir] ||= Dir.home

      p linux_config_dotfiles_ary(attr[:cfg_dir])
      p linux_local_dotfiles_ary(attr[:cfg_dir], attr[:local_dir])

      linux_config_dotfiles_ary(attr[:cfg_dir]).each do |config|
        linux_local_dotfiles_ary(attr[:cfg_dir], attr[:local_dir]).each do |local|
          next unless local == ".#{config}"

          cfg_file = File.join(File.expand_path(attr[:cfg_dir]), config)
          local_file = File.join(File.expand_path(attr[:local_dir]), local)
          Rake.cp(local_file, cfg_file)
        end
      end

      pull_sshd_config(attr[:sshd_local], attr[:cfg_dir])
      pull_gnome_term_settings(attr[:gnome_local], attr[:cfg_dir])
    end

    def self.pull_all_cygwin(attr = {})
      attr[:cfg_dir] ||= CONFIG_DIR
      attr[:local_dir] ||= Dir.home

      cygwin_config_dotfiles_ary(attr[:cfg_dir]).each do |config|
        cygwin_local_dotfiles_ary(attr[:cfg_dir], attr[:local_dir]).each do |local|
          cyg_zshrc = (config == 'cygwin_zshrc' && local == '.zshrc')
          next unless local == ".#{config}" || cyg_zshrc

          cfg_file = File.join(attr[:cfg_dir], config)
          local_file = File.join(attr[:local_dir], local)

          Rake.cp(local_file, cfg_file)
          puts "copying #{local_file} to #{cfg_file}"
        end
      end
    end

    # Must use foreach due to not having Dir.children in 2.3.3 for babun
    def self.linux_config_dotfiles_ary(dir = nil)
      dir ||= CONFIG_DIR

      Dir.entries(dir).reject do |file|
        NON_LINUX_DOTFILES.include?(file) || file =~ /\A\.{1,2}\Z/
      end
      # only returns dotfiles for linux
    end

    def self.cygwin_config_dotfiles_ary(dir = nil)
      dir ||= CONFIG_DIR

      Dir.entries(dir).reject do |file|
        # removes '.' && '..'
        NON_CYGWIN_DOTFILES.include?(file) || file =~ /\A\.{1,2}\Z/
      end
      # returns cygwin dotfiles
    end

    # *local_dotfiles_ary returns the files w/ a '.', ex: .vimrc
    def self.cygwin_local_dotfiles_ary(config_dir = nil, local_dir = nil)
      local_dir ||= Dir.home
      config_dir ||= CONFIG_DIR

      config_files = cygwin_config_dotfiles_ary(config_dir)

      Dir.entries(local_dir).select do |file|
        # checks that its a dotfile
        next unless file.start_with?('.')

        # removes pesky '.' & '..'
        next if file =~ /\A\.{1,2}\Z/

        # removes the . at the beginning of a dotfile
        config_file = file[1, file.length]
        config_file = 'cygwin_zshrc' if file == '.zshrc'

        config_files.include?(config_file)
      end
    end

    def self.linux_local_dotfiles_ary(config_dir = nil, local_dir = nil)
      config_dir ||= CONFIG_DIR
      local_dir ||= Dir.home

      config_files = linux_config_dotfiles_ary(config_dir)

      Dir.entries(local_dir).select do |file|
        next unless file.start_with?('.')
        next if file =~ /\A\.{1,2}\Z/

        config_file = file[1, file.length]
        config_files.include?(config_file)
      end
    end

    def self.pull_sshd_config(sshd_local_path = nil, sshd_config_path = nil)
      sshd_local_path ||= '/etc/ssh/sshd_config'
      sshd_config_path ||= File.join(CONFIG_DIR, 'sshd_config')

      # checks that there is a file to copy
      error = "#{sshd_local_path} does not exist. sshd_config not copied to cfg"
      return puts error unless File.exist?(sshd_local_path)

      Rake.cp(sshd_local_path, sshd_config_path)
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

    def self.gnome_dump(local_term = nil, config_term = nil)
      local_term ||= '/org/gnome/terminal/'
      config_term ||= File.join(CONFIG_DIR, 'gnome_terminal_settings')

      Rake.sh("dconf dump #{local_term} > #{config_term}")
    rescue RuntimeError
      dconf_not_installed
      false
    else
      puts "Gnome settings successfully dumped into #{config_term}"
      true
    end
  end

  def self.dconf_not_installed
    puts 'it appears you dont have dconf installed.'
    puts 'skipping dumping of gnome_settings'
    puts 'To install dconf, simply use'
    puts 'sudo apt-get install dconf-tools'
  end
end
