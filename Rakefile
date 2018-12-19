# frozen_string_literal: true

require 'fileutils'

LOAD_PATH = File.dirname(File.expand_path(__FILE__))
BACKUP_DIR = create_backup_dir

task :example do
  # p LOAD_PATH
  # sh 'echo', 'hi' # *cmd, &block
end

desc "copies files from config dir to home dir, will place existing dotfiles into #{BACKUP_DIR}"
task :copy_config do
  FileList.new(Dir.children('config')).each do |file|
    dot_file = ".#{file}"
    backup_file = "#{dot_file}.orig"

    # Copies to the backup dir if a .examplerc exists
    copy_file(dot_file, backup_file, BACKUP_DIR) 
    return #{dot_file} does not exist, no backup created" file_exists?(dot_file)
      

    # copies from vps-setup/config/file to ~/.examplerc
    copy_file(file, dot_file)
  end
end

private

# Defaults to Dir.home, can specify Dir, useful for backups
def copy_file(file, new_file, dir = Dir.home)
  new_file = File.join(dir, new_file)
  FileUtils.cp(file, new_file)
end

def file_exists?(file, dir = Dir.home)
  File.exist?(File.join(dir, file))
end

def create_backup_dir
  backup = 'backup_dotfiles'

  Dir.mkdir(File.join(Dir.home, backup)) unless Dir.exist?(backup)

  backup_dir(backup)
end

def backup_dir(name)
  Dir[File.join(Dir.home, name)]
end
