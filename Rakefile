# frozen_string_literal: true

require 'rake/testtask'
require './file_helper'

# LOAD_PATH = File.dirname(File.expand_path(__FILE__))
@fh = FileHelper.new
BACKUP_DIR = @fh.create_backup_dir

task :test do

end

task :example do
  # p LOAD_PATH
  # sh 'echo', 'hi' # *cmd, &block
end

desc "copies files from config dir to home dir, will place existing dotfiles into #{BACKUP_DIR}"
task :copy_config do
  FileList.new(Dir.children('config')).each do |file|
    dot_file = ".#{file}"
    backup_file = "#{dot_file}.orig"

    # Checks that there is a file to create
    unless file_exists?(dot_file)
      puts "#{file_path(dot_file)} does not exist, no backup created"
      next
    end

    if file_exist?(backup_file)
      puts "#{file_path(backup_file, BACKUP_DIR)} already exists, no backup created"
      next
    end

    # Copies to the backup dir if a .examplerc exists
    copy_file(dot_file, backup_file, BACKUP_DIR)

    # copies from vps-setup/config/file to ~/.examplerc
    copy_file(file, dot_file)
  end
end
