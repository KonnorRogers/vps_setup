# frozen_string_literal: true

require 'rake'

module VpsCli
  # Pull changes from local dir into config dir
  # to be able to push changes up to the config dir
  class Pull
    # Base pull method
    # @see VpsCli#create_options for the defaults
    # @param opts [Hash] Provides options for pulling files into a
    #   specific destination directory
    # @options opts [Dir] :local_dir ('$HOME')
    #   Where the local dotfiles are located
    # @option opts [Dir] :dotfiles_dir
    #   ('/path/to/vps_cli/config_files/dotfiles') Where to save the dotfiles to
    # @option opts [Dir] :misc_files_dir
    #   ('/path/to/vps_cli/config_files/misc_files')
    #   Location of misc_files in remote directory IE: git repo
    # @option opts [File] :local_sshd_config ('/etc/ssh/sshd_config')
    #   local directory containing sshd_config that currently exists
    # @option opts [Boolean] :verbose (false)
    #   Whether or not to print additional info

    def self.all(opts = {})
      opts = VpsCli.create_options(opts)

      # pulls dotfiles into specified directory
      dotfiles(opts)

      # pulls from opts[:local_sshd_config]
      sshd_config(opts)

      # pulls via dconf
      gnome_terminal_settings(opts)
    end

    # @see VpsCli#create_options for defaults
    # @param opts [Hash] Provides options for pulling dotfiles
    # @options opts [Dir] :local_dir ('$HOME') Where the dotfiles are locally
    # @options opts [Dir] :dotfiles_dir
    #   ('/path/to/vps_cli/config_files/dotfiles')
    #   location of the dotfiles to be modified
    # @options opts [Dir] :verbose (false)

    def self.dotfiles(opts = {})
      opts = VpsCli.create_options(opts)

      common_dotfiles(opts[:dotfiles_dir],
                      opts[:local_dir]) do |remote_file, local_file|
        copy_file_or_dir(local_file, remote_file)
      end
    end

    # Puts you at the point of a directory where the
    # local file and dotfile are the same allowing you to
    # copy them
    def self.common_dotfiles(dotfiles_dir, local_dir)
      Dir.each_child(dotfiles_dir) do |remote_file|
        Dir.each_child(local_dir) do |local_file|
          next unless local_file == ".#{remote_file}"

          remote_file = File.join(dotfiles_dir, remote_file)
          local_file = File.join(local_dir, local_file)
          yield(remote_file, local_file)
        end
      end
    end

    # Differentiates between files and dirs to appropriately copy them
    # Uses Rake.cp_r for directories, uses Rake.cp for simple files
    # @param orig_file [File, Dir] File or Dir you're copying from
    # @param new_file [File, Dir] File or Dir you're copying to
    # @param verbose [Boolean]
    def self.copy_file_or_dir(orig_file, new_file)
      if File.directory?(orig_file) && File.directory?(new_file)
        # Rake.cp_r(orig_file, new_file)
        Dir.each_child(orig_file) do |o_file|
          Dir.each_child(new_file) do |n_file|
            next unless o_file == n_file


            o_file = File.join(File.expand_path(orig_file), o_file)
            n_file = File.expand_path(new_file)

            p o_file
            p n_file
            Rake.cp_r(o_file, n_file)
          end
        end
      else
        Rake.cp(orig_file, new_file)
      end
    end

    # @see VpsCli#create_options for the defaults
    # @param opts [Hash] Provides options for pulling files into a
    #   specific destination directory
    # @option opts [File] :local_sshd_config ('/etc/ssh/sshd_config')
    #   directory containing sshd_config
    # @option opts [Dir] :misc_files_dir
    #   ('/path/to/vps_cli/config_files/misc_files')
    # @option opts [Boolean] :verbose (false)
    #   Whether or not to print additional info
    def self.sshd_config(opts = {})
      opts = VpsCli.create_options(opts)

      local = opts[:local_sshd_config]
      remote = opts[:misc_files_dir]

      copy_file_or_dir(local, remote)
    end

    # @see VpsCli#create_options for defaults
    # @param options [Hash] Provides options for pulling your gnome config
    # @option opts [Dir] :misc_files_dir
    #   ('/path/to/vps_cli/misc_files/gnome_terminal_settings')
    #   Where to save gnome settings
    # @option opts [Boolean] :verbose
    def self.gnome_terminal_settings(opts = {})
      opts = VpsCli.create_options(opts)

      # This is where dconf stores gnome terminal
      gnome_dconf = '/org/gnome/terminal/'
      remote_settings = File.join(opts[:misc_files_dir],
                                  'gnome_terminal_settings')

      orig_remote_contents = File.read(remote_settings)

      Rake.sh("dconf dump #{gnome_dconf} > #{remote_settings}")
    rescue RuntimeError => error
      VpsCli.errors << error
      # if dconf errors, it will erase the config file contents
      # So this protects against that
      reset_to_original(remote_settings, orig_remote_contents)
    else
      puts "Successfully dumped Gnome into #{remote_settings}" if opts[:verbose]
    end

    # Method intended for dealing with the way dconf will automatically
    # rewrite a file and make it empty
    # @param remote_settings [File] File located in your repo
    # @param orig_remote_contents [String] The String to be written to
    # remote settings
    def self.reset_to_original(remote_settings, orig_remote_contents)
      File.write(remote_settings, orig_remote_contents)
    end
  end
end
