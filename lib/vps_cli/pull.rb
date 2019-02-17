# frozen_string_literal: true

require 'rake'

module VpsCli
  # Pull changes from local dir into config dir
  # to be able to push changes up to the config dir
  class Pull
    ##
    # Base pull method
    # @param opts [Hash] opts various options for running the pull method
    def self.pull_all(opts = {})
      cfg_dir = opts[:cfg_dir]
      Rake.mkdir_p(File.expand_path(cfg_dir)) unless cfg_dir.nil? || Dir.exist?(cfg_dir)
      # checks for a blank dir, allows for pulling from vps_setup/config for testing output
      opts[:cfg_dir] = CONFIG_DIR if Dir.entries(cfg_dir).size == 2

      pull_all_linux(opts) if OS.linux?
    end

    def self.pull_all_linux(opts = {})
      opts[:cfg_dir] ||= CONFIG_DIR
      opts[:local_dir] ||= Dir.home
      opts[:gnome_local] ||= '/org/gnome/terminal/'

      linux_config_dotfiles_ary(opts[:cfg_dir]).each do |config|
        linux_local_dotfiles_ary(opts[:cfg_dir], opts[:local_dir]).each do |local|
          # IE: .vimrc .tmux.conf
          next unless local == ".#{config}"

          cfg_file = File.join(File.expand_path(opts[:cfg_dir]), config)
          local_file = File.join(File.expand_path(opts[:local_dir]), local)

          # Covers the case of .config
          if File.directory?(local_file)
            # only pulls whatever is present inside of vps_setup/config/config
            copy_directory(local_file, cfg_file)
          else
            Rake.cp(local_file, cfg_file)
          end
        end
      end

      pull_sshd_config(opts[:sshd_local], opts[:cfg_dir])
      pull_gnome_term_settings(opts[:gnome_local], opts[:cfg_dir])
    end

    # Must use foreach due to not having Dir.children in 2.3.3 for babun
    def self.linux_config_dotfiles_ary(dir = nil)
      dir ||= CONFIG_DIR

      Dir.entries(dir).reject do |file|
        NON_LINUX_DOTFILES.include?(file) || blank_file?(file)
      end
      # only returns dotfiles for linux
    end

    def self.linux_local_dotfiles_ary(config_dir = nil, local_dir = nil)
      config_dir ||= CONFIG_DIR
      local_dir ||= Dir.home

      config_files = linux_config_dotfiles_ary(config_dir)

      Dir.entries(local_dir).select do |file|
        next unless file.start_with?('.')
        next if blank_file?(file)

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
      config_term ||= File.join(CONFIG_DIR)
      config_term = File.join(CONFIG_DIR, 'gnome_terminal_settings')

      gnome_dump(local_term, config_term)
    end

    def self.gnome_dump(local_term = nil, config_term = nil)
      local_term ||= '/org/gnome/terminal/'
      config_term ||= File.join(CONFIG_DIR, 'gnome_terminal_settings')

      orig_config_contents = File.read(config_term) if File.exist?(config_term)

      Rake.sh("dconf dump #{local_term} > #{config_term}")
    rescue RuntimeError
      dconf_error
      # if dconf errors, it will erase the config file contents
      reset_to_original(config_term, orig_config_contents)
      false
    else
      puts "Gnome settings successfully dumped into #{config_term}"
      true
    end

    def self.dconf_error
      puts 'something went wrong. Gnome settings not saved.'
      puts 'You may not have dconf installed.'
      puts 'To install dconf, simply use'
      puts 'sudo apt-get install dconf-tools'
    end

    def self.reset_to_original(new_file, old_file_contents)
      return if old_file_contents.empty? # Ensures its copying a file with contents
      return unless File.zero?(new_file) # checks that the new file is empty

      # old_file_contents should be in string form
      File.write(new_file, old_file_contents)
    end

    def self.copy_directory(local_file, cfg_file)
      Dir.foreach(local_file) do |l_dir|
        next if blank_file?(l_dir)

        local_dir = File.join(local_file, l_dir)

        Dir.foreach(cfg_file) do |c_dir|
          next if blank_file?(c_dir)
          next unless c_dir == l_dir

          puts local_dir
          Rake.cp_r(local_dir, cfg_file)
        end
      end
    end
  end
end
