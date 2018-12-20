# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rake/testtask'
require './lib/file_helper'

# LOAD_PATH = File.dirname(File.expand_path(__FILE__))
@fh = FileHelper.new
BACKUP_DIR = @fh.create_backup_dir

task default: %w[test]

desc 'Runs tests'
task :test do
  Rake::TestTask.new do |t|
    t.libs << 'lib'
    t.libs << 'test'
    t.test_files = FileList['test/test*.rb']
  end
end

desc "copies files from config dir to home dir, will place existing dotfiles into #{BACKUP_DIR}"
task :copy_config do
  FileList.new(Dir.children('config')).each do |file|
    dot_file = ".#{file}"
    backup_file = "#{dot_file}.orig"

    # Checks that there is a file to create
    if file_exist?(dot_file) && file_exist?(backup_file)
      copy_file(dot_file, backup_file, BACKUP_DIR)
    end

    if file_exist?(dot_file)
      # If back up file exists, do not create a back
      if file_exist?(backup_file)
        puts "#{file_path(backup_file)} already exists. No backup created"
      else
        copy_file(dot_file, backup_file, BACKUP_DIR)
      end
    else
      puts "#{file_path(dot_file)} does not exist, no backup created"
      next
    end

    # Checks that a backup file hasnt already been created
    if file_exist?(backup_file)
      puts "#{file_path(backup_file, BACKUP_DIR)} already exists, no backup created"
      next
    else
      copy_file(dot_file, backup_file, BACKUP_DIR)
    end
  end
end
