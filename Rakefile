# frozen_string_literal: true

require 'fileutils'

LOAD_PATH = File.dirname(File.expand_path(__FILE__))
BACKUP_DIR = Dir[File.join(Dir.home, 'backup_dotfiles')]

task :example do
  # p LOAD_PATH
  # sh 'echo', 'hi' # *cmd, &block
end

desc "copies files from config dir to home dir, will place existing dotfiles into #{BACKUPDIR}"
task :copy_config do
  # Creates backup directory
  create_backup_dir

  FileList.new(Dir.children('config')).each do |file|
    dot_file = ".#{file}"
    backup_file = "#{dot_file}.orig"


    # Copies to the backup dir if a .examplerc exists
    copy_file(dot_file, backup_file, BACKUP_DIR) if file_exists?(dot_file)
    
    # copies from vps-setup/config/file to ~/.examplerc
    copy_file(file, dot_file)

  end
end

private

# Defaults to Dir.home, can specify Dir, useful for backups
def copy_file(file, new_file, dir = Dir.home)
  FileUtils.cp(file, File.join(dir, new_file))
end

def file_exists?(file)
  File.exist?(File.join(Dir.home, file))
end

def create_backup_dir
  return if Dir.exist?('backup_dotfiles')
  
  Dir.mkdir(File.join(Dir.home, 'backup_dotfiles'))
end
