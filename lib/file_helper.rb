require 'fileutils'

class FileHelper
  # Defaults to Dir.home, can specify Dir, useful for backups
  def copy_file(file, new_file, dir = Dir.home)
    new_file = File.join(dir, new_file)
    FileUtils.cp(file, new_file)
  end

  def file_exist?(file, dir = Dir.home)
    File.exist?(File.join(dir, file))
  end

  def file_path(file, dir = Dir.home)
    File.expand_path(File.join(dir, file))
  end

  def create_backup_dir
    backup = 'backup_dotfiles'

    Dir.mkdir(File.join(Dir.home, backup)) unless Dir.exist?(File.join(Dir.home, backup))

    backup_dir(backup)
  end

  def backup_dir(name)
    Dir[File.join(Dir.home, name)]
  end
end
