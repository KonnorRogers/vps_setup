# frozen_string_literal: true

require 'rake'

# Used for copying files, making directories, copying directories etc
module FileHelper
  # Helper method for making multiple directories
  # @param [Dir, Array<Dir>] Creates either one, or multiple directories
  def self.mkdirs(*dirs)
    dirs.flatten.each { |dir| Rake.mkdir_p(dir) unless Dir.exist?(dir) }
  end

  # Copies files, called by copy_all
  # @param config_file [File] The file from the repo to be copied locally
  # @param dot_file [File] The file that is currently present locally
  # @param backup_file [File]
  #   The file to which to save the currently present local file
  # @param verbose [Boolean] Will print more info to terminal if true
  def self.copy_files(config_file, dot_file, backup_file, verbose = false)
    # if there is an original dot file & no backup file in the backupdir
    # Copy the dot file to the backup dir
    if create_backup?(dot_file, backup_file, verbose)
      Rake.cp(dot_file, backup_file)
    end

    # Copies from vps_cli/dotfiles to the location of the dot_file
    Rake.cp(config_file, dot_file)
  end

  ##
  # Copies directories instead of file
  # @param config_file [Dir] The Dir from the repo to be copied locally
  # @param dot_file [Dir] The Dir that is currently present locally
  # @param backup_file [Dir]
  #   The Dir to which to save the currently present local file
  # @param verbose [Boolean] Will print additional info to terminal if true
  def self.copy_dirs(config_dir, local_dir, backup_dir, verbose = false)
    if create_backup?(local_dir, backup_dir, verbose)
      Rake.cp_r(local_dir, backup_dir)
    end

    Rake.mkdir_p(local_dir) unless Dir.exist?(local_dir)

    Dir.each_child(config_dir) do |dir|
      dir = File.join(config_dir, dir)

      Rake.cp_r(dir, local_dir)
    end
  end

  ##
  # Checks that a backup file does not exist
  # @param file [File] File to be searched for
  # @param verbose [Boolean] Will print to console if verbose == true
  # @return [Boolean] Returns true if the file is not found
  def self.backup_file_not_found?(file, verbose = false)
    return true unless File.exist?(file)

    puts "#{file} exists already. No backup created." if verbose
    false
  end

  ##
  # Helper method for determining whether or not to create a backup file
  # @param local_file [File] current dot file
  # @param backup_file [File] Where to back the dot file up to
  # @param verbose [Boolean] Will print to terminal if verbose == true
  # @return [Boolean] Returns true if there is a dotfile that exists
  #   And there is no current backup_file found
  def self.create_backup?(local_file, backup_file, verbose = false)
    return false unless file_found?(local_file, verbose)
    return false unless backup_file_not_found?(backup_file, verbose)

    true
  end

  ##
  # Default way of checking if the dotfile already exists
  # @param file [File] File to be searched for
  # @param verbose [Boolean] Will print to console if verbose == true
  # @return [Boolean] Returns true if the file exists
  def self.file_found?(file, verbose = false)
    return true if File.exist?(file)

    puts "#{file} does not exist. No backup created." if verbose
    false
  end
end
