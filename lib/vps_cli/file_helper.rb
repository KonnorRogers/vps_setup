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
  # @see VpsCli::Copy#all
  # @param [Hash] opts The options to copy with
  # @option opts [File] :config_file The file from the repo to be copied locally
  # @option opts [File] :local_file The file that is currently present locally
  # @option opts [File] :backup_file
  #   The file to which to save the currently present local file
  # @option opts [Boolean] :interactive
  #   Will prompt yes or no for each file it creates
  # @option opts [Boolean] :verbose Will print more info to terminal if true
  def self.copy_files(opts = {})
    # if there is an original dot file & no backup file in the backupdir
    # Copy the dot file to the backup dir
    if create_backup?(opts)
      copy_file(opts[:local_file], opts[:backup_file], opts[:interactive])
    end

    # Copies from vps_cli/dotfiles to the location of the dot_file
    copy_file(opts[:config_file], opts[:local_file], opts[:interactive])
  end

  # Copies directories instead of files, called by copy_all
  # @see VpsCli::Copy#all
  # @param [Hash] opts The options to copy with
  # @option opts [File] :config_file The file from the repo to be copied locally
  # @option opts [File] :dot_file The file that is currently present locally
  # @option opts [File] :backup_file
  #   The file to which to save the currently present local file
  # @option opts [Boolean] :interactive
  #   Will prompt yes or no for each file it creates
  # @option opts [Boolean] :verbose Will print more info to terminal if true
  def self.copy_dirs(opts = {})
    mkdirs(opts[:local_file])

    if create_backup?(opts)
      copy_dir(opts[:local_file], opts[:backup_file], opts[:interactive])
    end

    Dir.each_child(opts[:config_file]) do |dir|
      dir = File.join(opts[:config_file], dir)

      # copies to local dir
      copy_dir(dir, opts[:local_file], opts[:interactive])
    end
  end

  # Checks that a backup file does not exist
  # @param file [File] File to be searched for
  # @param verbose [Boolean] Will print to console if verbose == true
  # @return [Boolean] Returns true if the file is not found
  def self.backup_file_not_found?(file, verbose = false)
    return true unless File.exist?(file)

    puts "#{file} exists already. No backup created." if verbose
    false
  end

  # Helper method for determining whether or not to create a backup file
  # @param opts [Hash] options hash
  # @option [File] :local_file current dot file
  # @option [File] :backup_file Where to back the dot file up to
  # @option [Boolean] :verbose Will print to terminal if verbose == true
  # @return [Boolean] Returns true if there is a dotfile that exists
  #   And there is no current backup_file found
  def self.create_backup?(opts = {})
    return false unless file_found?(opts[:local_file], opts[:verbose])
    unless backup_file_not_found?(opts[:backup_file], opts[:verbose])
      return false
    end

    true
  end

  # Default way of checking if the dotfile already exists
  # @param file [File] File to be searched for
  # @param verbose [Boolean] Will print to console if verbose == true
  # @return [Boolean] Returns true if the file exists
  def self.file_found?(file, verbose = false)
    return true if File.exist?(file)

    puts "#{file} does not exist. No backup created." if verbose
    false
  end

  def self.retrieve_file(directory, name)
    Dir.children(directory).select { |file| name == file }
  end

  # base method to copy a file and ask for permission prior to copying
  # @see copy_files
  # @see ask_permission
  # @param from [File] File to copy from
  # @param to [File] File to copy to
  # @param interactive [Boolean] (false) asks whether or not to create the file
  def self.copy_file(from, to, interactive = false)
    Rake.cp(from, to) if overwrite?(to, interactive)
  end

  # base method to copy a dir and ask for permission prior to copying
  # @see copy_dirs
  # @see ask_permission
  # @param from [Dir] Directory to copy from
  # @param to [Dir] Directory to copy to
  # @param interactive [Boolean] (false) asks whether or not to create the file
  def self.copy_dir(from, to, interactive = false)
    mkdirs(to)

    to_path = File.join(to, File.basename(from))
    Rake.cp_r(from, to) if overwrite?(to_path, interactive)
  end

  # asks permission to copy a file
  # @param file [File] The file to copy to
  # @param interactive [Boolean] (false) If interactive equals false
  #   then automatically overwrite
  # @return [Boolean]
  #   Decides whether or not the file will be created / overwritted
  def self.overwrite?(file, interactive = false)
    return true if interactive == false

    string = "Attempting to overwrite file #{file}" if File.exist?(file)
    string ||= "Attempting to create file #{file}"

    # +string is equivalent to string.dup
    string = +string + ' Is this okay? (Y/N)'

    loop do
      puts string
      input = $stdin.gets.chomp.downcase.to_sym
      return true if input == :y
      return false if input == :n
    end
  end
end
